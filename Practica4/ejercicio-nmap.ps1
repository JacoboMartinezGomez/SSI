function Extraer-ZIP($file, $destination) {
  $shell = new-object -com shell.application
  $zip = $shell.NameSpace($file)
  $shell.NameSpace($destination).copyhere($zip.items())
}

function Preparar-Imagen($nombre_imagen, $url_base_origen, $dir_base_destino) {
  if(!(Test-Path -Path "$dir_base_destino\$nombre_imagen.vdi"))  {
      if(!(Test-Path -Path "$dir_base_destino\$nombre_imagen.vdi.zip"))  {
           Write-Host "Iniciando descarga de $url_base_origen/$nombre_imagen.vdi.zip ..."
           $web_client = New-Object System.Net.WebClient
           $web_client.DownloadFile("$url_base_origen/$nombre_imagen.vdi.zip", "$dir_base_destino\$nombre_imagen.vdi.zip")
      }
      Write-Host "Descomprimiendo $dir_base_destino\$nombre_imagen.vdi.zip ..."
      Extraer-Zip "$dir_base_destino\$nombre_imagen.vdi.zip" "$dir_base_destino"
      Remove-Item "$dir_base_destino\$nombre_imagen.vdi.zip"
  }
}

####
####   MAIN
####

$URL_BASE="http://ccia.esei.uvigo.es/docencia/SSI/1920/practicas"
$DIR_BASE="D:\SSI1920"


if(!(Test-Path -Path $DIR_BASE))  {
   New-Item $DIR_BASE -itemtype directory
}

Preparar-Imagen "swap1GB" "$URL_BASE" "$DIR_BASE"
Preparar-Imagen "base_ssi" "$URL_BASE" "$DIR_BASE"

Write-Host ">> SSI 2019/20 -- Ejemplo Wireshark y nmap"
$ID = Read-Host "Introducir identificador de las MVs"

$BASE_VBOX = $env:VBOX_MSI_INSTALL_PATH
if ([string]::IsNullOrEmpty($BASE_VBOX)) {
   $BASE_VBOX = $env:VBOX_INSTALL_PATH
}
if ([string]::IsNullOrEmpty($BASE_VBOX)) {
   $READ_BASE_VBOX = Read-Host ">> Introducir directorio de instalacion de VirtualBox (habitualente `"C:\\Program Files\Oracle\VirtualBox`") :"
   if ([string]::IsNullOrEmpty($READ_BASE_VBOX)) {
      $READ_BASE_VBOX = "`"C:\\Program Files\Oracle\VirtualBox`""
   }
   $BASE_VBOX = $READ_BASE_VBOX
}

$VBOX_MANAGE = "$BASE_VBOX\VBoxManage.exe"

echo $VBOX_MANAGE

Write-Host ">> Configurando maquinas virtuales ..."

$MV_INTERNO1="INTERNO1_$ID"
if(!(Test-Path -Path "$DIR_BASE\$MV_INTERNO1"))  {
  Start-Process $VBOX_MANAGE  "createvm  --name $MV_INTERNO1 --basefolder `"$DIR_BASE`" --register" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "storagectl $MV_INTERNO1 --name STORAGE_$MV_INTERNO1  --add sata --portcount 4" -NoNewWindow -Wait     
  Start-Process $VBOX_MANAGE  "storageattach $MV_INTERNO1 --storagectl STORAGE_$MV_INTERNO1 --port 0 --device 0 --type hdd --medium `"$DIR_BASE\base_ssi.vdi`" --mtype multiattach" -NoNewWindow -Wait 
  Start-Process $VBOX_MANAGE  "storageattach $MV_INTERNO1 --storagectl STORAGE_$MV_INTERNO1 --port 1 --device 0 --type hdd --medium `"$DIR_BASE\swap1GB.vdi`" --mtype immutable" -NoNewWindow -Wait 
  Start-Process $VBOX_MANAGE  "modifyvm $MV_INTERNO1 --memory 512 --pae on --vram 16" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "modifyvm $MV_INTERNO1 --nic1 intnet --intnet1 vlan1 --macaddress1 080027111111 --cableconnected1 on --nictype1 82540EM" -NoNewWindow -Wait  

  Start-Process $VBOX_MANAGE  "guestproperty set $MV_INTERNO1 /DSBOX/num_interfaces 1" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_INTERNO1 /DSBOX/eth/0/type static" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_INTERNO1 /DSBOX/eth/0/address 192.168.100.11" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_INTERNO1 /DSBOX/eth/0/netmask 24" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_INTERNO1 /DSBOX/default_gateway 192.168.100.1" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_INTERNO1 /DSBOX/host_name interno1.ssi.net" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_INTERNO1 /DSBOX/etc_hosts_dump `"interno1.ssi.net:192.168.100.11,interno2.ssi.net:192.168.100.22,observador.ssi.net:192.168.100.33`"" -NoNewWindow -Wait
}

$MV_INTERNO2="INTERNO2_$ID"
if(!(Test-Path -Path "$DIR_BASE\$MV_INTERNO2"))  {
  Start-Process $VBOX_MANAGE  "createvm  --name $MV_INTERNO2 --basefolder `"$DIR_BASE`" --register" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "storagectl $MV_INTERNO2 --name STORAGE_$MV_INTERNO2  --add sata --portcount 4" -NoNewWindow -Wait     
  Start-Process $VBOX_MANAGE  "storageattach $MV_INTERNO2 --storagectl STORAGE_$MV_INTERNO2 --port 0 --device 0 --type hdd --medium `"$DIR_BASE\base_ssi.vdi`" --mtype multiattach" -NoNewWindow -Wait 
  Start-Process $VBOX_MANAGE  "storageattach $MV_INTERNO2 --storagectl STORAGE_$MV_INTERNO2 --port 1 --device 0 --type hdd --medium `"$DIR_BASE\swap1GB.vdi`" --mtype immutable" -NoNewWindow -Wait 
  Start-Process $VBOX_MANAGE  "modifyvm $MV_INTERNO2 --memory 256 --pae on --vram 16" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "modifyvm $MV_INTERNO2 --nic1 intnet --intnet1 vlan1 --macaddress1 080027222222 --cableconnected1 on --nictype1 82540EM" -NoNewWindow -Wait  

  Start-Process $VBOX_MANAGE  "guestproperty set $MV_INTERNO2 /DSBOX/num_interfaces 1" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_INTERNO2 /DSBOX/eth/0/type static" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_INTERNO2 /DSBOX/eth/0/address 192.168.100.22" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_INTERNO2 /DSBOX/eth/0/netmask 24" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_INTERNO2 /DSBOX/default_gateway 192.168.100.1" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_INTERNO2 /DSBOX/host_name interno2.ssi.net" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_INTERNO2 /DSBOX/etc_hosts_dump `"interno1.ssi.net:192.168.100.11,interno2.ssi.net:192.168.100.22,observador.ssi.net:192.168.100.33`"" -NoNewWindow -Wait
}

$MV_OBSERVADOR="OBSERVADOR_$ID"
if(!(Test-Path -Path "$DIR_BASE\$MV_OBSERVADOR"))  {
  Start-Process $VBOX_MANAGE  "createvm  --name $MV_OBSERVADOR --basefolder `"$DIR_BASE`" --register" -NoNewWindow -Wait    
  Start-Process $VBOX_MANAGE  "storagectl $MV_OBSERVADOR --name STORAGE_$MV_OBSERVADOR  --add sata --portcount 4" -NoNewWindow -Wait     
  Start-Process $VBOX_MANAGE  "storageattach $MV_OBSERVADOR --storagectl STORAGE_$MV_OBSERVADOR --port 0 --device 0 --type hdd --medium `"$DIR_BASE\base_ssi.vdi`" --mtype multiattach" -NoNewWindow -Wait      
  Start-Process $VBOX_MANAGE  "storageattach $MV_OBSERVADOR --storagectl STORAGE_$MV_OBSERVADOR --port 1 --device 0 --type hdd --medium `"$DIR_BASE\swap1GB.vdi`" --mtype immutable" -NoNewWindow -Wait      
  Start-Process $VBOX_MANAGE  "modifyvm $MV_OBSERVADOR --memory 512 --pae on --vram 16" -NoNewWindow -Wait     
  Start-Process $VBOX_MANAGE  "modifyvm $MV_OBSERVADOR --nic1 intnet --intnet1 vlan1 --macaddress1 080027333333 --nicpromisc1 allow-all --cableconnected1 on --nictype1 82540EM" -NoNewWindow -Wait      

  Start-Process $VBOX_MANAGE  "guestproperty set $MV_OBSERVADOR /DSBOX/num_interfaces 1" -NoNewWindow -Wait     
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_OBSERVADOR /DSBOX/eth/0/type static" -NoNewWindow -Wait     
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_OBSERVADOR /DSBOX/eth/0/address 192.168.100.33" -NoNewWindow -Wait     
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_OBSERVADOR /DSBOX/eth/0/netmask 24" -NoNewWindow -Wait     
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_OBSERVADOR /DSBOX/default_gateway 192.168.100.1" -NoNewWindow -Wait     
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_OBSERVADOR /DSBOX/host_name observador.ssi.net" -NoNewWindow -Wait     
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_OBSERVADOR /DSBOX/etc_hosts_dump `"interno1.ssi.net:192.168.100.11,interno2.ssi.net:192.168.100.22,observador.ssi.net:192.168.100.33`" " -NoNewWindow -Wait     
}


Write-Host "Arrancando maquinas virtuales ..."
Start-Process $VBOX_MANAGE  "startvm $MV_INTERNO1"
Start-Process $VBOX_MANAGE  "startvm $MV_INTERNO2"
Start-Process $VBOX_MANAGE  "startvm $MV_OBSERVADOR"

Start-Process $VBOX_MANAGE  "controlvm $MV_ATACANTE clipboard bidirectional" -NoNewWindow -Wait 
Start-Process $VBOX_MANAGE  "controlvm $MV_MODSECURITY clipboard bidirectional" -NoNewWindow -Wait 
Start-Process $VBOX_MANAGE  "controlvm $MV_VICTIMA clipboard bidirectional" -NoNewWindow -Wait 

Write-Host "Maquinas virtuales arrancadas"