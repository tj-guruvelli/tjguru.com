filename=$(ls -Art /mnt/c/Users/$USER/Desktop/ss 2>/dev/null | tail -n 1)
echo "The file name is $filename"

if [ -n "$filename" ]; then
  # Create destination directory if it doesn't exist
  mkdir -p "$(dirname "$(pwd)/../../assets/posts/gatech/dl/$1")"
  
  # Copy the file
  cp "/mnt/c/Users/$USER/Desktop/ss/$filename" "$(pwd)/../../assets/posts/gatech/dl/$1"
  
  # Generate markdown and copy to clipboard (using clip.exe for Windows clipboard)
  echo "![image](../../../assets/posts/gatech/dl/$1){: width='400' height='400'}" | clip.exe
  echo "Image markdown copied to clipboard"
else
  echo "No screenshot found"
fi