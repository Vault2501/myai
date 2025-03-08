import yaml
#import urllib.request
import requests
import hashlib
import sys
import os
import shutil
from pathlib import Path


def check_sha256(filename, sha256):
    """Check if the file with the name "filename" matches the SHA-256 sum
    in "expect"."""
    h = hashlib.sha256()
    # This will raise an exception if the file doesn't exist. Catching
    # and handling it is left as an exercise for the reader.
    with open(filename, 'rb') as fh:
        # Read and hash the file in 4K chunks. Reading the whole
        # file at once might consume a lot of memory if it is
        # large.
        while True:
            data = fh.read(4096)
            if len(data) == 0:
                break
            else:
                h.update(data)
    return sha256 == h.hexdigest()


def download(url, file):
    print("  - Downloading model ", file)
    path = os.path.dirname(file)

    print("    URL:  ", url)
    print("    FILE: ", file)
 
    if not os.path.exists(path):
        os.makedirs(path)

    response = requests.get(url, stream=True)
    with open(file, mode="wb") as filehandle:
        for chunk in response.iter_content(chunk_size=1000 * 1024):
            filehandle.write(chunk)
            #print(os.path.getsize(file)/1024+'KB / '+size+' KB downloaded!', end='\r')
            print(str(os.path.getsize(file)/1024)+'KB / ', end='\r')


def check_model(model_file, model_sha256):
    print("  - Checking if model exists at ", model_file)
    if (os.path.exists(model_file)):
        print("  - Model exists, checking sha256")
        if check_sha256(model_file, model_sha256):
            print("  - Model file sha256 ok")
            return True
        else:
            print("  - Model file sha256 not ok")
            return False
    else:
        print("  - Model does not exist")
        return False



def check_cache(model, cache_path):
    cache_file = cache_path+model['filename']
    print("  - Checking cache", cache_path, " for ", cache_file)

    if (os.path.exists(cache_file)):
        print("  - Cache file found, checking sha256")
        if check_sha256(cache_file, model['sha256']):
            print("  - Cache file sha256 ok")
            return True
        else:
            print("  - Cache file sha256 not ok")
            return False
    else:
        print("  - Cache file not found")
        return False

            
def copy_cache(model, cache_path, model_file):
    cache_file = cache_path+model['filename']
    print("  - Copying ", cache_file, " from cache to ", model_file)
    shutil.copyfile(cache_file, model_file)


def backup(model, cache_path, model_file):
    cache_file = cache_path+model['filename']
    print("  - Copying ", model_file, " to cache ", cache_file)
    shutil.copyfile(model_file, cache_file)


def install_pack(pack, model_dir, cache_dir):
    print("Installing pack:", pack['name'])

    for model in pack['models']:
        print("  Installing model:", model['filename'])

        model_file = model_dir+model['path']+model['filename']
        cache_path = cache_dir+model['path'] 

        if (not check_model(model_file, model['sha256'])):
            if (check_cache(model, cache_path)):
                copy_cache(model, cache_path, model_file)
            else:
                download(model['url'],model_file)
                if (check_sha256(model_file, model['sha256'])):
                    backup(model, cache_path, model_file)
                else:
                    print("  - sha256 wrong, download failed")


with open('../config/models.yaml', 'r') as modelsFile:
    packs = yaml.safe_load(modelsFile)

base_dir  = os.path.dirname(__file__)+'/../'
model_dir = base_dir+packs['modeldir']
cache_dir = packs['cachedir']+packs['modeldir']


for pack in packs['packs']:
    install_pack(pack, model_dir, cache_dir)


