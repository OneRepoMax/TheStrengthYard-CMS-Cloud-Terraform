###########
#Author Ankit Gupta
#Cloud Engineer
#Automation to install Webserver and create a new web page
###########

<powershell>
# :: Installing IIS Web Server
DISM /Online /Enable-Feature /All /FeatureName:IIS-WebServer /NoRestart

# :: Change location
cd C:\inetpub\wwwroot

# :: List of Directory
dir

# :: creating a directory
mkdir dd

# :: ii* -  The File names which start with ii are moved to the directory dd
move ii* dd/

# :: Creating a new html file 
echo This is my new WebPage >index.html

# :: Go to localhost
start http://127.0.0.1
</powershell>