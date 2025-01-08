## Configuring Nginx to Proxy to S3 Static Website

This guide explains how to configure Nginx on your AWS EC2 instance to proxy requests to an S3 bucket hosting your static website.

---

## **Steps to Follow**

`configure s3`
### **Step 1: Upload Files to S3**
1. Create an S3 Bucket:
    - Ensure the bucket is public (or use signed URLs if privacy is required).

2. Upload Your Static Files:
     - Use the AWS Management Console, AWS CLI, or any other S3 client to upload your files.


### **Step 2: Configure S3 Bucket**

1. Enable Static Website Hosting:
     - Go to your bucket properties, enable static website hosting, and note the bucket's public URL (e.g., `http://your-bucket-name.s3-website-region.amazonaws.com`).

2. Update Permissions:
     - Attach an S3 bucket policy to allow public read access for your files if necessary:

     ```json
     {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Effect": "Allow",
               "Principal": "*",
               "Action": "s3:GetObject",
               "Resource": "arn:aws:s3:::your-bucket-name/*",
               "Condition": {
                   "IpAddress": {
                       "aws:SourceIp": "54.242.219.154"
                   }
               }
           }
       ]
    }

    ```




### **Step 3: Update the Nginx Configuration**
Edit your Nginx configuration file (usually located at `/etc/nginx/sites-available/default`) to include the following proxy configuration:

```nginx
server {
    listen 80;
    server_name <your-ec2-public-ip>;

    location / {
        proxy_pass http://bkt-my-web-server-nginx.s3-website-us-east-1.amazonaws.com;

        # Explicitly set the Host header to the full S3 static website URL
        proxy_set_header Host bkt-my-web-server-nginx.s3-website-us-east-1.amazonaws.com;

        # Forward the real client IP and any forwarded-for headers
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```
Replace `your-ec2-public-ip` with your EC2 instance's public IP address.


### **Step 4: Test the Nginx Configuration**
Before reloading Nginx, test the configuration to ensure there are no syntax errors:
```bash
sudo nginx -t
```
If the test is successful, proceed to reload Nginx.


### **Step 5: Reload Nginx**
Reload Nginx to apply the updated configuration:

```bash
sudo systemctl reload nginx
```

### **Step 6: Verify the Setup**
Open a browser and navigate to `http://your-ec2-public-ip` (replace `your-ec2-public-ip` with the public IP address of your EC2 instance). The content from the S3 bucket should load correctly.

