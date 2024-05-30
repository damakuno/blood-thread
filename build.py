import os
from zipfile import ZipFile
import shutil
from pathlib import Path
import subprocess

game_name = 'bloodsewn'
output_love_file = f'./dist/{game_name}.love'
output_zip_file = f'./out/{game_name}.zip'
output_web_zip_file = f'./out/{game_name}_web.zip'
love_path = 'C:\\Program Files\\LOVE\\'

if not os.path.exists('./dist'):
    os.mkdir('./dist')
if not os.path.exists('./web_dist'):
    os.mkdir('./web_dist')
if not os.path.exists('./out'):
    os.mkdir('./out')

# Create object of ZipFile
with ZipFile(output_love_file, 'w') as zip_object:
   # Traverse all files in directory
   for folder_name, sub_folders, file_names in os.walk('./'):
        if folder_name not in ['.git', './.vscode', './dist', './out']:
            if './.git' not in folder_name and './web_dist' not in folder_name:
                # print('folder_name:', folder_name, 'sub_folders:', sub_folders, 'file_names:', file_names)
                for filename in file_names:
                    if filename not in [
                            'build.py',
                            '.gitignore',
                            f'{game_name}.zip'                        
                        ]:                        
                        print(f'Copying to dist/: {folder_name}/{filename}')
                        # Create filepath of files in directory
                        file_path = os.path.join(folder_name, filename)                         
                        # Add files to zip file
                        zip_object.write(file_path, file_path)#os.path.basename(file_path))
                    else:
                        print(f'Skipped: {folder_name}{filename}')

if os.path.exists(output_love_file):
   print(f"{output_love_file} created")
else:
   print(f"{output_love_file} not created")


shutil.copytree('./config', './dist/config/', dirs_exist_ok=True)
shutil.copytree('./levels', './dist/levels/', dirs_exist_ok=True)

for file_type in ['.json', '.md']:
    for path in Path('.').glob(f'*{file_type}'):
        shutil.copyfile(path, Path('./dist/') / (path.stem + path.suffix))

love_absolute_dir = Path(output_love_file).resolve()
output_exe_dir = Path(f'./dist/{game_name}.exe').resolve()

cmd = f'copy /b "{love_path}love.exe"+"{love_absolute_dir}" "{output_exe_dir}"'
print(f'building exe to: {output_exe_dir} from {output_love_file}...')
print(cmd)
os.system(cmd)

print('copying dlls and license.txt...')
for path in Path(love_path).glob('*.dll'):
    shutil.copyfile(path, Path('./dist') / (path.stem + path.suffix))
shutil.copyfile(Path(love_path) / 'license.txt', Path('./dist') / 'license.txt')

cmd = f'npx love.js.cmd -m 40000000 -t {game_name} "{love_absolute_dir}" .\\web_dist\\'
print(f'building web build to: .\\web_dist\\...')
print(cmd)
os.system(cmd)

print(f'deleting love archive: {output_love_file}...')
os.remove(output_love_file)
if os.path.exists(output_love_file):
   print(f"{output_love_file} not deleted")
else:
   print(f"{output_love_file} deleted")

print(f'creating final archive: {output_zip_file}...')

with ZipFile(output_zip_file, 'w') as zip_object:
    for folder_name, sub_folders, file_names in os.walk('./dist/'):                    
        for filename in file_names:
            print(f'Adding to final archive: {folder_name}/{filename}')
            # Create filepath of files in directory
            file_path = os.path.join(folder_name, filename)                         
            # Add files to zip file
            zip_object.write(file_path, file_path)

print(f'creating final web archive: {output_web_zip_file}...')
with ZipFile(output_web_zip_file, 'w') as zip_object:
    for folder_name, sub_folders, file_names in os.walk('./web_dist/'):                    
        for filename in file_names:
            print(f'Adding to final archive: {folder_name}/{filename}')
            # Create filepath of files in directory
            file_path = os.path.join(folder_name, filename)                         
            # Add files to zip file
            zip_object.write(file_path, file_path)