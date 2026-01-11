"""
LTX-2 RunPod Serverless Handler

Supports:
- Text-to-Video (T2V) and Image-to-Video (I2V)
- Fast mode (distilled model) and Pro mode (dev model)
- Camera control LoRAs
- 720p and 1080p resolutions
- 10s, 15s, 20s durations
"""

import runpod
import os
import websocket
import base64
import json
import uuid
import logging
import urllib.request
import urllib.parse
import binascii
import subprocess
import time
import random

# Logging configuration
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# ComfyUI server address
server_address = os.getenv('SERVER_ADDRESS', '127.0.0.1')
client_id = str(uuid.uuid4())

# Workflow file paths (relative to container root)
WORKFLOW_FILES = {
    ('t2v', 'fast'): '/ltx2_t2v_fast_api.json',
    ('t2v', 'pro'): '/ltx2_t2v_pro_api.json',
    ('i2v', 'fast'): '/ltx2_i2v_fast_api.json',
    ('i2v', 'pro'): '/ltx2_i2v_pro_api.json',
}

# Node ID mappings per workflow type
NODE_MAPPINGS = {
    ('t2v', 'fast'): {
        'prompt': '5222',
        'width': '5217',
        'height': '5217',
        'frames': '5218',
        'seed': '5237154',
        'camera_lora_1': '5230',
        'camera_lora_2': '5231',
    },
    ('t2v', 'pro'): {
        'prompt': '5225',
        'width': '5232',
        'height': '5232',
        'frames': '5233',
        'seed': '5266248',
        'camera_lora_1': '5221',
        'camera_lora_2': '5222',
    },
    ('i2v', 'fast'): {
        'prompt': '5175',
        'image': '5180',
        'width': '5185',
        'height': '5185',
        'frames': '5186',
        'seed': '5194097',
        'camera_lora_1': '5182',
        'camera_lora_2': '5183',
    },
    ('i2v', 'pro'): {
        'prompt': '5175',
        'image': '5180',
        'width': '5185',
        'height': '5185',
        'frames': '5186',
        'seed': '5194097',
        'camera_lora_1': '5182',
        'camera_lora_2': '5183',
    },
}

# Camera LoRA file mapping
CAMERA_LORAS = {
    'static': 'ltx-2-19b-lora-camera-control-static.safetensors',
    'dolly_in': 'ltx-2-19b-lora-camera-control-dolly-in.safetensors',
    'dolly_out': 'ltx-2-19b-lora-camera-control-dolly-out.safetensors',
    'dolly_left': 'ltx-2-19b-lora-camera-control-dolly-left.safetensors',
    'dolly_right': 'ltx-2-19b-lora-camera-control-dolly-right.safetensors',
    'jib_up': 'ltx-2-19b-lora-camera-control-jib-up.safetensors',
    'jib_down': 'ltx-2-19b-lora-camera-control-jib-down.safetensors',
}


def to_nearest_multiple_of_32(value):
    """Adjust value to nearest multiple of 32 (LTX-2 requirement)."""
    try:
        numeric_value = float(value)
    except Exception:
        raise Exception(f"width/height value is not a number: {value}")
    adjusted = int(round(numeric_value / 32.0) * 32)
    if adjusted < 32:
        adjusted = 32
    return adjusted


def duration_to_frames(seconds):
    """Convert duration in seconds to frame count at 24fps."""
    # LTX-2 uses 24fps, formula: frames = seconds * 24 + 1
    return int(seconds * 24) + 1


def process_input(input_data, temp_dir, output_filename, input_type):
    """Process input data and return file path."""
    if input_type == "path":
        logger.info(f"Path input: {input_data}")
        return input_data
    elif input_type == "url":
        logger.info(f"URL input: {input_data}")
        os.makedirs(temp_dir, exist_ok=True)
        file_path = os.path.abspath(os.path.join(temp_dir, output_filename))
        return download_file_from_url(input_data, file_path)
    elif input_type == "base64":
        logger.info("Base64 input processing")
        return save_base64_to_file(input_data, temp_dir, output_filename)
    else:
        raise Exception(f"Unsupported input type: {input_type}")


def download_file_from_url(url, output_path):
    """Download file from URL using wget."""
    try:
        result = subprocess.run(
            ['wget', '-O', output_path, '--no-verbose', url],
            capture_output=True, text=True, timeout=60
        )
        if result.returncode == 0:
            logger.info(f"Downloaded: {url} -> {output_path}")
            return output_path
        else:
            logger.error(f"wget failed: {result.stderr}")
            raise Exception(f"URL download failed: {result.stderr}")
    except subprocess.TimeoutExpired:
        logger.error("Download timeout")
        raise Exception("Download timeout")
    except Exception as e:
        logger.error(f"Download error: {e}")
        raise Exception(f"Download error: {e}")


def save_base64_to_file(base64_data, temp_dir, output_filename):
    """Save base64 encoded data to file."""
    try:
        decoded_data = base64.b64decode(base64_data)
        os.makedirs(temp_dir, exist_ok=True)
        file_path = os.path.abspath(os.path.join(temp_dir, output_filename))
        with open(file_path, 'wb') as f:
            f.write(decoded_data)
        logger.info(f"Saved base64 to: {file_path}")
        return file_path
    except (binascii.Error, ValueError) as e:
        logger.error(f"Base64 decode failed: {e}")
        raise Exception(f"Base64 decode failed: {e}")


def queue_prompt(prompt):
    """Send workflow prompt to ComfyUI."""
    url = f"http://{server_address}:8188/prompt"
    logger.info(f"Queueing prompt to: {url}")
    p = {"prompt": prompt, "client_id": client_id}
    data = json.dumps(p).encode('utf-8')
    req = urllib.request.Request(url, data=data)
    return json.loads(urllib.request.urlopen(req).read())


def get_history(prompt_id):
    """Get execution history from ComfyUI."""
    url = f"http://{server_address}:8188/history/{prompt_id}"
    logger.info(f"Getting history from: {url}")
    with urllib.request.urlopen(url) as response:
        return json.loads(response.read())


def get_videos(ws, prompt):
    """Wait for workflow completion and extract video output."""
    prompt_id = queue_prompt(prompt)['prompt_id']
    output_videos = {}

    while True:
        out = ws.recv()
        if isinstance(out, str):
            message = json.loads(out)
            if message['type'] == 'executing':
                data = message['data']
                if data['node'] is None and data['prompt_id'] == prompt_id:
                    break
        else:
            continue

    history = get_history(prompt_id)[prompt_id]
    for node_id in history['outputs']:
        node_output = history['outputs'][node_id]
        videos_output = []
        if 'gifs' in node_output:
            for video in node_output['gifs']:
                with open(video['fullpath'], 'rb') as f:
                    video_data = base64.b64encode(f.read()).decode('utf-8')
                videos_output.append(video_data)
        output_videos[node_id] = videos_output

    return output_videos


def load_workflow(workflow_path):
    """Load workflow JSON file."""
    with open(workflow_path, 'r') as file:
        return json.load(file)


def inject_parameters(workflow, workflow_type, params):
    """Inject parameters into workflow nodes."""
    mapping = NODE_MAPPINGS[workflow_type]

    # Inject prompt
    prompt_node = mapping['prompt']
    workflow[prompt_node]['inputs']['value'] = params['prompt']
    logger.info(f"Injected prompt into node {prompt_node}")

    # Inject resolution
    width_node = mapping['width']
    height_node = mapping['height']
    adjusted_width = to_nearest_multiple_of_32(params['width'])
    adjusted_height = to_nearest_multiple_of_32(params['height'])
    workflow[width_node]['inputs']['width'] = adjusted_width
    workflow[height_node]['inputs']['height'] = adjusted_height
    logger.info(f"Injected resolution: {adjusted_width}x{adjusted_height}")

    # Inject frame count
    frames_node = mapping['frames']
    frames = duration_to_frames(params['duration'])
    workflow[frames_node]['inputs']['value'] = frames
    logger.info(f"Injected frames: {frames} ({params['duration']}s at 24fps)")

    # Inject seed
    seed_node = mapping['seed']
    seed = params.get('seed', random.randint(0, 2**32 - 1))
    workflow[seed_node]['inputs']['noise_seed'] = seed
    logger.info(f"Injected seed: {seed}")

    # Inject camera LoRA
    camera_lora = params.get('camera_lora', 'static')
    lora_file = CAMERA_LORAS.get(camera_lora, CAMERA_LORAS['static'])
    lora_node_1 = mapping['camera_lora_1']
    lora_node_2 = mapping['camera_lora_2']
    workflow[lora_node_1]['inputs']['lora_name'] = lora_file
    workflow[lora_node_2]['inputs']['lora_name'] = lora_file
    logger.info(f"Injected camera LoRA: {camera_lora} -> {lora_file}")

    # Inject image path (I2V only)
    if 'image' in mapping and params.get('image_path'):
        image_node = mapping['image']
        workflow[image_node]['inputs']['image'] = params['image_path']
        logger.info(f"Injected image path: {params['image_path']}")

    return workflow


def handler(job):
    """RunPod serverless handler for LTX-2 video generation."""
    job_input = job.get("input", {})
    logger.info(f"Received job input: {job_input}")

    try:
        # Parse and validate input
        prompt = job_input.get("prompt")
        if not prompt:
            return {"error": "Missing required parameter: prompt"}

        gen_type = job_input.get("type", "t2v").lower()
        if gen_type not in ["t2v", "i2v"]:
            return {"error": f"Invalid type: {gen_type}. Must be 't2v' or 'i2v'"}

        mode = job_input.get("mode", "fast").lower()
        if mode not in ["fast", "pro"]:
            return {"error": f"Invalid mode: {mode}. Must be 'fast' or 'pro'"}

        width = job_input.get("width", 1280)
        height = job_input.get("height", 720)
        duration = job_input.get("duration", 10)
        seed = job_input.get("seed")
        camera_lora = job_input.get("camera_lora", "static")

        # Validate camera_lora
        if camera_lora not in CAMERA_LORAS:
            logger.warning(f"Unknown camera_lora '{camera_lora}', using 'static'")
            camera_lora = "static"

        # Validate duration
        if duration not in [10, 15, 20]:
            logger.warning(f"Unusual duration: {duration}s, using anyway")

        # Create task directory for temporary files
        task_id = f"task_{uuid.uuid4()}"

        # Process image input for I2V
        image_path = None
        if gen_type == "i2v":
            if "image_url" in job_input:
                image_path = process_input(job_input["image_url"], task_id, "input_image.jpg", "url")
            elif "image_base64" in job_input:
                image_path = process_input(job_input["image_base64"], task_id, "input_image.jpg", "base64")
            else:
                return {"error": "I2V requires image_url or image_base64"}

        # Select and load workflow
        workflow_type = (gen_type, mode)
        workflow_path = WORKFLOW_FILES[workflow_type]
        logger.info(f"Using workflow: {workflow_path}")
        workflow = load_workflow(workflow_path)

        # Prepare parameters
        params = {
            'prompt': prompt,
            'width': width,
            'height': height,
            'duration': duration,
            'seed': seed,
            'camera_lora': camera_lora,
            'image_path': image_path,
        }

        # Inject parameters into workflow
        workflow = inject_parameters(workflow, workflow_type, params)

        # Connect to ComfyUI
        http_url = f"http://{server_address}:8188/"
        logger.info(f"Checking HTTP connection to: {http_url}")

        # HTTP health check (max 3 minutes)
        max_http_attempts = 180
        for http_attempt in range(max_http_attempts):
            try:
                urllib.request.urlopen(http_url, timeout=5)
                logger.info(f"HTTP connection successful (attempt {http_attempt + 1})")
                break
            except Exception as e:
                logger.warning(f"HTTP connection failed (attempt {http_attempt + 1}/{max_http_attempts}): {e}")
                if http_attempt == max_http_attempts - 1:
                    raise Exception("Cannot connect to ComfyUI server")
                time.sleep(1)

        # WebSocket connection (max 3 minutes)
        ws_url = f"ws://{server_address}:8188/ws?clientId={client_id}"
        logger.info(f"Connecting to WebSocket: {ws_url}")

        ws = websocket.WebSocket()
        max_ws_attempts = 36  # 3 minutes with 5s intervals
        for attempt in range(max_ws_attempts):
            try:
                ws.connect(ws_url)
                logger.info(f"WebSocket connection successful (attempt {attempt + 1})")
                break
            except Exception as e:
                logger.warning(f"WebSocket connection failed (attempt {attempt + 1}/{max_ws_attempts}): {e}")
                if attempt == max_ws_attempts - 1:
                    raise Exception("WebSocket connection timeout (3 minutes)")
                time.sleep(5)

        # Execute workflow and get video
        videos = get_videos(ws, workflow)
        ws.close()

        # Return first video found
        for node_id in videos:
            if videos[node_id]:
                return {"video": videos[node_id][0]}

        return {"error": "No video output found"}

    except Exception as e:
        logger.error(f"Handler error: {e}")
        return {"error": str(e)}


# Start RunPod serverless handler
runpod.serverless.start({"handler": handler})
