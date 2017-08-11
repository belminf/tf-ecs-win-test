resource "aws_launch_configuration" "default" {
  image_id                    = "${var.ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  associate_public_ip_address = true
  security_groups             = ["${aws_security_group.default.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.default.id}"

  user_data = <<EOF
<powershell>
  # Set agent env variables for the Machine context (durable)  
  [Environment]::SetEnvironmentVariable("ECS_CLUSTER", "${aws_ecs_cluster.default.name}", "MACHINE")
  $agentVersion = 'v1.14.3';
  $agentZipUri = "https://s3.amazonaws.com/amazon-ecs-agent/ecs-agent-windows-$agentVersion.zip";
  $agentZipMD5Uri = "$agentZipUri.md5";
  $ecsExeDir = "$env:ProgramFiles\\Amazon\\ECS";
  $zipFile = "$env:TEMP\\ecs-agent.zip";
  echo "log" >> c:\\windows\\temp\\log1.txt;
  echo $zipFile >> c:\\windows\\temp\\log1.txt;
  echo $ecsExeDir >> c:\\windows\\temp\\log1.txt;
  $md5File = "$env:TEMP\\ecs-agent.zip.md5";
  Invoke-RestMethod -OutFile $zipFile -Uri $agentZipUri;
  Invoke-RestMethod -OutFile $md5File -Uri $agentZipMD5Uri;
  $expectedMD5 = (Get-Content $md5File);
  $md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider;
  $actualMD5 = [System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::ReadAllBytes($zipFile))).replace("-", "");
if($expectedMD5 -ne $actualMD5) {
    echo "Download does not match hash.";
    echo "Expected: $expectedMD5 - Got: $actualMD5";
    exit 1;
  
};
  Expand-Archive -Path $zipFile -DestinationPath $ecsExeDir -Force;
  $jobname = "ECS-Agent-Init";
  $script =  "cd '$ecsExeDir'; .\\amazon-ecs-agent.ps1";
  $repeat = (New-TimeSpan -Minutes 1);
  $jobpath = $env:LOCALAPPDATA + "\\Microsoft\\Windows\\PowerShell\\ScheduledJobs\\$jobname\\ScheduledJobDefinition.xml";
if($(Test-Path -Path $jobpath)) {
    echo "Job definition already present";
    exit 0;
  
}
  $scriptblock = [scriptblock]::Create("$script");
  $trigger = New-JobTrigger -At (Get-Date).Date -RepeatIndefinitely -RepetitionInterval $repeat -Once;
  $options = New-ScheduledJobOption -RunElevated -ContinueIfGoingOnBattery -StartIfOnBattery;
  Register-ScheduledJob -Name $jobname -ScriptBlock $scriptblock -Trigger $trigger -ScheduledJobOption $options -RunNow;
  Add-JobTrigger -Name $jobname -Trigger (New-JobTrigger -AtStartup -RandomDelay 00:1:00);
  echo $scriptblock >> c:\\windows\\temp\\log1.txt;
  echo $trigger >> c:\\windows\\temp\\log1.txt;
  echo $options >> c:\\windows\\temp\\log1.txt; 
</powershell>\n
<persist>true</persist>
EOF
}

resource "aws_autoscaling_group" "default" {
  vpc_zone_identifier  = ["${aws_subnet.subnet1.id}", "${aws_subnet.subnet2.id}"]
  launch_configuration = "${aws_launch_configuration.default.name}"
  max_size             = "${var.max_size}"
  min_size             = "${var.min_size}"
  desired_capacity     = "${var.desired_capacity}"
}
