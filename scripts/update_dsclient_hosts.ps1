$order_id=$args[0]
$region=$args[1]

$hostlocation='c:\Windows\System32\drivers\etc\hosts'

do
{
  $nlb=(aws ssm get-parameter --name /$order_id/master_nlb_dnsname --query Parameter.Value --output text --region $region)
} while (!$nlb)

add-content $hostlocation "$nlb  is-en-conductor-0.en-cond"

# New-Item -Path "c:\" -Name "udran" -ItemType "file"
