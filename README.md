# The Neural Image Art Web Service

This web application uses a RESTful API service that is similar in function to the popular iOS application Prisma. This application uses a neural network to merge two photographs into a single photograph. The service is packaged as a Docker image

## To use the application run the commands below:
- sudo docker build -t fh-home-flaskapp .
- sudo docker run -d -p 8080:5000 -v $(pwd)/content_img_dir:/app/neural-style-tf/content_image \
                          -v $(pwd)/style_imgs_dir:/app/neural-style-tf/style_image \
                          -v $(pwd)/img_output_dir:/app/neural-style-tf/result_image \
                          fh-home-flaskapp 
- curl -F "content_image=@/home/fh/Desktop/content1.png" -F"style_image=@/home/fh/Desktop/style.png" localhost:8080/run > result1.png

The sample input files content1.png and style.png are in the repository. The output file result1.png generated using the application has also been uploaded. 
