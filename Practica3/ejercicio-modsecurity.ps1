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


Write-Host ">> SSI 2019/20 -- Ejemplo de uso de ModSecurity"
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

$MV_ATACANTE="ATACANTE2_$ID"
if(!(Test-Path -Path "$DIR_BASE\$MV_ATACANTE"))  {
  Start-Process $VBOX_MANAGE  "createvm  --name $MV_ATACANTE --basefolder `"$DIR_BASE`" --register" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "storagectl $MV_ATACANTE --name STORAGE_$MV_ATACANTE  --add sata --portcount 4" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "storageattach $MV_ATACANTE --storagectl STORAGE_$MV_ATACANTE --port 0 --device 0 --type hdd --medium `"$DIR_BASE\base_ssi.vdi`" --mtype multiattach" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "storageattach $MV_ATACANTE --storagectl STORAGE_$MV_ATACANTE --port 1 --device 0 --type hdd --medium `"$DIR_BASE\swap1GB.vdi`" --mtype immutable" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "modifyvm $MV_ATACANTE --memory 2048 --pae on --vram 16" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "modifyvm $MV_ATACANTE --nic1 intnet --intnet1 vlan1 --macaddress1 080027111111 --cableconnected1 on --nictype1 82540EM" -NoNewWindow -Wait

  Start-Process $VBOX_MANAGE  "guestproperty set $MV_ATACANTE /DSBOX/num_interfaces 1" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_ATACANTE /DSBOX/eth/0/type static" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_ATACANTE /DSBOX/eth/0/address 198.51.100.111" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_ATACANTE /DSBOX/eth/0/netmask 24" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_ATACANTE /DSBOX/default_gateway 198.51.100.1" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_ATACANTE /DSBOX/default_nameserver 8.8.8.8" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_ATACANTE /DSBOX/host_name atacante.ssi.net" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_ATACANTE /DSBOX/etc_hosts_dump `"atacante.ssi.net:198.51.100.111,modsecurity.ssi.net:198.51.100.112,victima.ssi.net:198.51.100.113`"  " -NoNewWindow -Wait
}
Start-Process $VBOX_MANAGE  "guestproperty set $MV_ATACANTE /DSBOX/etc_hosts_dump `"atacante.ssi.net:198.51.100.111,modsecurity.ssi.net:198.51.100.112,victima.ssi.net:198.51.100.113`"  " -NoNewWindow -Wait



$MV_VICTIMA="VICTIMA_$ID"
if(!(Test-Path -Path "$DIR_BASE\$MV_VICTIMA"))  {
  Start-Process $VBOX_MANAGE  "createvm  --name $MV_VICTIMA --basefolder `"$DIR_BASE`" --register" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "storagectl $MV_VICTIMA --name STORAGE_$MV_VICTIMA  --add sata --portcount 4" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "storageattach $MV_VICTIMA --storagectl STORAGE_$MV_VICTIMA --port 0 --device 0 --type hdd --medium `"$DIR_BASE\base_ssi.vdi`" --mtype multiattach" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "storageattach $MV_VICTIMA --storagectl STORAGE_$MV_VICTIMA --port 1 --device 0 --type hdd --medium `"$DIR_BASE\swap1GB.vdi`" --mtype immutable" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "modifyvm $MV_VICTIMA --memory 512 --pae on --vram 16" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "modifyvm $MV_VICTIMA --nic1 intnet --intnet1 vlan1 --macaddress1 080027111114 --cableconnected1 on --nictype1 82540EM" -NoNewWindow -Wait

  Start-Process $VBOX_MANAGE  "guestproperty set $MV_VICTIMA /DSBOX/num_interfaces 1" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_VICTIMA /DSBOX/eth/0/type static" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_VICTIMA /DSBOX/eth/0/address 198.51.100.113" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_VICTIMA /DSBOX/eth/0/netmask 24" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_VICTIMA /DSBOX/default_gateway 198.51.100.1" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_VICTIMA /DSBOX/default_nameserver 8.8.8.8" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_VICTIMA /DSBOX/host_name victima.ssi.net" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_VICTIMA /DSBOX/etc_hosts_dump `"atacante.ssi.net:198.51.100.111,modsecurity.ssi.net:198.51.100.112,victima.ssi.net:198.51.100.113`"  " -NoNewWindow -Wait
}


$MV_MODSECURITY="MODSECURITY_$ID"
if(!(Test-Path -Path "$DIR_BASE\$MV_MODSECURITY"))  {
  Start-Process $VBOX_MANAGE  "createvm  --name $MV_MODSECURITY --basefolder `"$DIR_BASE`" --register" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "storagectl $MV_MODSECURITY --name STORAGE_$MV_MODSECURITY  --add sata --portcount 4" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "storageattach $MV_MODSECURITY --storagectl STORAGE_$MV_MODSECURITY --port 0 --device 0 --type hdd --medium `"$DIR_BASE\base_ssi.vdi`"     --mtype multiattach" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "storageattach $MV_MODSECURITY --storagectl STORAGE_$MV_MODSECURITY --port 1 --device 0 --type hdd --medium `"$DIR_BASE\swap1GB.vdi`" --mtype immutable" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "modifyvm $MV_MODSECURITY --memory 512 --pae on --vram 16" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "modifyvm $MV_MODSECURITY --nic1 intnet --intnet1 vlan1 --macaddress1 080027111112 --cableconnected1 on --nictype1 82540EM" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "modifyvm $MV_MODSECURITY --nic2 nat --macaddress2 080027111113 --cableconnected2 on --nictype2 82540EM" -NoNewWindow -Wait

  Start-Process $VBOX_MANAGE  "guestproperty set $MV_MODSECURITY /DSBOX/num_interfaces 2" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_MODSECURITY /DSBOX/eth/0/type static" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_MODSECURITY /DSBOX/eth/0/address 198.51.100.112" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_MODSECURITY /DSBOX/eth/0/netmask 24" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_MODSECURITY /DSBOX/eth/1/type static" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_MODSECURITY /DSBOX/eth/1/address 10.0.3.15" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_MODSECURITY /DSBOX/eth/1/netmask 24" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_MODSECURITY /DSBOX/default_gateway 10.0.3.2" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_MODSECURITY /DSBOX/default_nameserver 8.8.8.8" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_MODSECURITY /DSBOX/host_name modsecurity.ssi.net" -NoNewWindow -Wait
  Start-Process $VBOX_MANAGE  "guestproperty set $MV_MODSECURITY /DSBOX/etc_hosts_dump `"atacante.ssi.net:198.51.100.111,modsecurity.ssi.net:198.51.100.112,victima.ssi.net:198.51.100.113`"  " -NoNewWindow -Wait
}


Start-Process $VBOX_MANAGE  "startvm $MV_ATACANTE"
Start-Process $VBOX_MANAGE  "startvm $MV_MODSECURITY"
Start-Process $VBOX_MANAGE  "startvm $MV_VICTIMA"
Start-Process $VBOX_MANAGE  "controlvm $MV_ATACANTE clipboard bidirectional"
Start-Process $VBOX_MANAGE  "controlvm $MV_MODSECURITY clipboard bidirectional"
Start-Process $VBOX_MANAGE  "controlvm $MV_VICTIMA clipboard bidirectional"
