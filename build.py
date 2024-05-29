import os
from zipfile import ZipFile

# Create object of ZipFile
with ZipFile('./dist/bloodsewn.love', 'w') as zip_object:
   # Traverse all files in directory
   for folder_name, sub_folders, file_names in os.walk('./'):
        if folder_name not in ['.git', './.vscode', './dist']:
            if './.git' not in folder_name:
                print('folder_name:', folder_name, 'sub_folders:', sub_folders, 'file_names:', file_names)
                for filename in file_names:
                    if filename not in [
                            'build.py',
                            '.gitignore'                        
                        ]:
                        # Create filepath of files in directory
                        file_path = os.path.join(folder_name, filename)                         
                        # Add files to zip file
                        zip_object.write(file_path, file_path)#os.path.basename(file_path))

if os.path.exists('./dist/bloodsewn.love'):
   print("./dist/bloodsewn.love created")
else:
   print("./dist/bloodsewn.love not created")

