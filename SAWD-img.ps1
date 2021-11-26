#This will self elevate the script so with a UAC prompt since this script needs to be run as an Administrator in order to function properly.
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Write-Host "You didn't run this program as an Administrator. This program will self elevate to run as an Administrator and continue."
    Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}
Write-Host ("Welcome to SAWD `n Collection of scripts for windows `n strap up and have fun `n")

#global values
$global:chochek = Read-Host "enable offline mode? y/n"
#Menus and other cool stuff
$global:usertext="*" 
$global:sidetext="*"
$global:imagetorender = "https://i.postimg.cc/43TqqttW/sawd-baner.png"

#table that contains text that will be rendered alongside the image
function sidemenu{
	[string[]] $sidetab= @()
	$sidetab = $usertext
	$sidetab = $sidetab.Split('\')
	$global:sidetext = $sidetab
	
}
#fancy graphic in powershell 
#this part is a modified version of code by DevAndersen  
function printimage{
	function RenderImage([System.Drawing.Image]$Image)
	{
		$tick=0
		[Console]::CursorVisible = $false
		for ($y = 0; $y -lt $Image.Height; $y += 2)
		{
			$pixelStrings = for ($x = 0; $x -lt $Image.Width; $x++)
			{
				$f = $Image.GetPixel($x, $y)
				"$escape[38;2;$($f.R);$($f.G);$($f.b)m"
				
				if ($y -lt $Image.Height - 1)
				{
					$b = $Image.GetPixel($x, $y + 1)
					"$escape[48;2;$($b.R);$($b.G);$($b.B)m"
				}
				
				$halfCharString
			}
			[String]::Join('', $pixelStrings + "$escape[0m"+$sidetext[$tick])
			$tick++
		}
		[Console]::CursorVisible = $true
	}

	function ResizeImage([System.Drawing.Image]$Image, $NewWidth, $NewHeight)
	{
		return $img.GetThumbnailImage($NewWidth, $NewHeight, $null, [IntPtr]::Zero)
	}

	function LoadImage()
	{
		#You cna choose what image will be rendered here
		$Path=$imagetorender
		$webClient = [System.Net.WebClient]::new()
		$imageStream = [System.IO.MemoryStream]::new($webClient.DownloadData($Path))
		$webClient.Dispose()
		$img = [System.Drawing.Image]::FromStream($imageStream, $false, $false)
		$imageStream.Dispose()
		return $img
	}

	#endregion

	#region Main flow

	[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

	$escape = [Char]0x1B
	$halfCharString = [Char]0x2580

	$img = LoadImage

	switch ($PSCmdlet.ParameterSetName)
	{
		"Resize"
		{
			$img = ResizeImage -Image $img -NewWidth $Width -NewHeight $Height
		}
		"FillMode"
		{
			switch ($FillMode)
			{
				"Stretch"
				{
					$w = [Console]::WindowWidth
					$h = [Console]::WindowHeight * 2
				}
				"ProportionalWidth"
				{
					$w = [Console]::WindowWidth
					$h = ($img.Height / $img.Width) * [Console]::WindowWidth
				}
				"ProportionalHeight"
				{
					$w = ($img.Height / $img.Width) * [Console]::WindowHeight * 2
					$h = [Console]::WindowHeight * 2
				}
			}
			
			$img = ResizeImage -Image $img -NewWidth $w -NewHeight $h
		}
	}

	RenderImage -Image $img 

	$img.Dispose()

	#endregion
}


########Instalowanie programów##############################################################
#Zautomatyzowane instalowanie prgramów odbywa się poprzez wykorzystanie programu chocolatey#
############################################################################################

# chcoaltey instalation (used for auto installing programs) 
function hotchoco {
	   [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	  # Set-ExecutionPolicy Unrestricted	
}

#instalator sterowników GPU (oparty na chcoaltey)
function gpudriver {
	$d=1
	#sterowniki do karty i "idioto odporna" pentla
	do {
		Write-Host "`n Choose GPU vendor:`n `n	1- NVIDIA `n	2- AMD `n	3- intel `n	4- exit"
		$gpu = Read-Host ">_SAWD\GpuDriver\"
		if ($gpu -eq "1" -Or $gpu -eq "2" -Or $gpu -eq "3" -Or $gpu -eq "4"){
			$d=1
		} else {
			Write-Host "zle dane!" -BackgroundColor Red
			$d=0
		}
	} while ($d -lt 1)

	#instalowanie sterowników do gpu 
	switch ($gpu)
	{
		1 {"nvidia"; choco install nvidia-display-driver geforce-experience -y}
		2 {"amd"; Write-Host "(Sterowniki kart AMD muszą zostać zainstalowane ręcznie)`n AMD CRIMSON: https://www.amd.com/en/support/kb/release-notes/rn-rad-win-17-11-4 `n STEROWNIKI https://www.amd.com/en/support"-BackgroundColor Red 
		
		pause}
		3 {"intel"; echo choco install intel-graphics-driver -y}
	}
}

#wybierajka programów (oparty na chocolatey)
function proginstaller{
	#mnenu jest tylko po to zeby wiadomo bylo co instalujesz
	Write-Host "`n AUTO INSTALL: " 


	#jak dodajesz jakis program to dodaj go rowniez do menu mozesz uzyc litery cyfry albo ciagu liter (stringa)

	#przebrzydły oneliner
	Write-Host " 1- Firefox `n 2- chrome `n 3- Brave `n 4- Libreoffice `n 5- 7zip `n 6- VLC `n 7- Thunderbird `n 8-Notepad++ `n custom- Install custom porgrams `n allsens- sensible defaults for user PC (chrome+firefox browser) `n exit- returns to previous menu" 
	#kod na tablice
	[string[]] $prog= @()
	$prog = READ-HOST ">_SAWD\PROGINSTALLER\ "
	$prog = $prog.Split(',').Split(' ')
	$prog
	#instalacja programów
	switch ($prog)
	{
		"allsens" {"wszystko";choco install googlechrome libreoffice-fresh 7zip vlc thunderbird -y 
		}
		"exit" {"bye!";}
		1 {"Firefox"; choco install firefox -y}
		2 {"Chrome"; choco install googlechrome -y}
		3 {"brave"; choco install brave -y}
		4 {"Libreoffice";choco install libreoffice-fresh -y}
		5 {"7zip";choco install 7zip -y}
		6 {"VLC";choco install vlc -y}
		7 {"Thunderbird";choco install thunderbird -y}
		8 {"Notepad++"; choco install notepadplusplus -y}
		"custom" {"Specify what programs you wish to install:";customprog}
		#jak wczesniejsze instrukcje byly nie jasne to daj se tu co chesz z gory skopiuj linijke i zmien cyferke oraz podaj nazwe programu powodzenia 
	}
}
function customprog {
	$cprog = READ-HOST ">_SAWD\PROGINSTALLER\CUSTOM\"
	$cprog = $cprog.Split(',').Split(' ')
	choco install $cprog -y
}
########Skryty##############################################################################
#Przydatne skrypty serwisowe 															   #
############################################################################################



function firewall_utl{
	Write-Host ("`n Welcome to firewall configurator `n `n `n ")
	do{
		#define auxiliary variables 
		$d=0
		$status=0
		$tick=1
		$ctick=0
		$tack=0
		[string[]] $cords= @() 
		[string[]] $fire= @()
		$fire = READ-HOST ">_SAWD\FIREWALL_CONFIG\"
		$fire = $fire+" "
		$fire = $fire.Split(' ')
		$rulename=$fire[0]
		$traffic=$fire[1]
		$protocol=$fire[2]
		$port=$fire[3]
		$subprofile=$fire[4]
		$policy=$fire[5]
		Write-Host($rulename, $traffic, $protocol, $port, $subprofile, $policy)
		switch ($fire) {
		"exit"{""; $d=1; $status=1}
		"help"{firehelp; $status=1}
		"/?"{firehelp; $status=1}
		"--help"{firehelp; $status=1}
		"clear" {cls; $status=1}
		"cls" {cls; $status=1}
		}
		$chtraffic="false"
		$chprotocol="false"
		$chsubprofile="false"
		$chpolicy="false"
		if ($traffic -eq "in" -Or $traffic -eq "out" -Or $traffic -eq "both"){$chtraffic="true"}
		#write-host("check traffic", $chtraffic)
		if ($protocol -eq "tcp" -Or  $protocol -eq "udp" -Or $protocol -eq "both"){$chprotocol="true"}
		#write-host ("protocol ",$chprotocol)
		if ($subprofile -eq "public" -Or $subprofile -eq "private" -Or $subprofile -eq "both" -Or $subprofile -eq "domain"){$chsubprofile="true"}		
		#write-host ("check profile", $chsubprofile)
		if ($policy -eq ""){$policy="allow"}
		if ($policy -eq "allow" -Or $policy -eq "deny") {$chpolicy="true"}
		
		if ($rulename -eq "load.profile"){
				Write-Host "yeah booi" 
		} elseif ($chtraffic -eq "true" -And $chprotocol -eq "true" -And $chsubprofile -eq "true" -And $chpolicy -eq "true"){ 
				[string[]] $trules= @() 
				[string[]] $prules= @() 
				[string[]] $srules= @() 
				
				if ($traffic -eq "both") {
					$trules = "in out"
					$tick=$tick*2
				} else {$trules = $traffic+" "+$traffic}
				
				if ($protocol -eq "both") {
					$prules = "tcp udp"
					$tick=$tick*2
				} else {$prules = $protocol+" "+$protocol}
				
				if ($subprofile -eq "both") {
					$srules = "private public"
					$tick=$tick*2
				} else {$srules = $subprofile+" "+$subprofile}
				
				$trules = $trules.Split(',').Split(' ')
				$prules = $prules.Split(',').Split(' ')
				$srules = $srules.Split(',').Split(' ')
				
				if ($tick -eq "2") {$cords = $cords+"0 0 0 1 1 1"}
				if ($tick -eq "4") {
					if ($protocol -eq "both" -and $subprofile -eq "both"){
						$cords = $cords+"0 0 0 0 0 1 0 1 1 0 1 0"
					} else {
						$cords = $cords+"0 0 0 1 1 1 0 1 1 1 0 0"
					}
				}
				if ($tick -eq "8") {$cords = $cords+"0 0 0 0 0 1 0 1 0 0 1 1 1 0 0 1 0 1 1 1 0 1 1 1"}
				if ($tick -eq "1") {$cords = "1 1 1"}
				$cords = $cords.Split(',').Split(' ')

				do {
					#write-host ("traffic: ",$trules[$cords[$tack]],"protocol: ",$prules[$cords[$tack+1]],"subprofile: ",$srules[$cords[$tack+2]])
					$rulenamed = $rulename+"_"+$prules[$cords[$tack+1]].ToUpper()+"_"+$trules[$cords[$tack]].ToUpper()+"_"+$srules[$cords[$tack+2]].ToUpper()
					write-host ("netsh advfirewall firewall add rule name = ",$rulenamed," dir = ",$trules[$cords[$tack]],"protocol = ",$prules[$cords[$tack+1]],"action = ",$policy," localport = ",$port,"remoteip = localsubnet profile = ",$srules[$cords[$tack+2]])
					$g=$g+("`n netsh advfirewall firewall add rule name = ",$rulenamed," dir = ",$trules[$cords[$tack]]," protocol = ",$prules[$cords[$tack+1]]," action = ",$policy," localport = ",$port," remoteip = localsubnet profile = ",$srules[$cords[$tack+2]])
					$tack=$tack+3
					$ctick=$ctick+1
				} while ($ctick -lt $tick)
				$g| out-file -FilePath .\firewallrules.bat -NoNewline
				
		} elseif ($status -eq "0") {
				write-host "invalid syntax"
				firehelp
		}

			
	} while ($d -lt 1)
}


function firehelp {
	Write-Host ("`n syntax: [rule_name in/out protocol port subnet_profile]  `n `n about: `n avalible protocols: TCP UDP or BOTH  `n avalible subnet profiles: PRIVATE PUBLIC or BOTH `n avalible In/out rules: IN OUT or BOTH `n `n You can also apply preconfigured profile template `n load profile syntax: [load.profile profile_name] `n `n Profiles: `n subiekt: optimized firewall rules for subiektGT server `n `n `n ")
}
function debloat{
	iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Sycnex/Windows10Debloater/master/Windows10Debloater.ps1'))
}

function mailfix {
	$zipFile = "https://drive.google.com/uc?export=download&id=1bzLqyYmzECmsmneDagI0lJ9l_W2nA3Tn"
	Invoke-WebRequest -Uri $zipFile -OutFile ".\file.reg"
	.\file.reg
	pause
	rm .\file.reg
}

function offlinemenu {
	Write-Host (" ----------SAWD-CLI----------`n |Made by: Marcin Rypień    |`n |Version: 0.3              |`n ----------------------------`n `n `n `n **MAIN MODULE - OFFLINE MODE** `n You can choose one or multiple scripts to run`n`n `n firewallconfig: configure windows firewall`n fixlivemail: fix SubiektGT - Windows Live Mail `n integration`n`n polkit: Set polkit to Allsigned`n debloat: Windows 10 debloater script `n exit: exits the program")
}

function onlinemenu {
	$global:usertext=" ----------SAWD-CLI----------\ |Made by: Marcin Rypień    |\ |Version: 0.3              |\ ----------------------------\ \ \ \ **MAIN MODULE - ONLINE MODE ** \ You can choose one or multiple scripts to run\\ choman: Install chocolatey \ pakage manager for Windows\\ *proginstaller: Automated program installer \ *gpudrv: Automated GPU drivers installer \ *cholist: list packages\\ firewallconfig: configure windows firewall\ fixlivemail: fix SubiektGT - Windows Live Mail \ integration\\ polkit: Set polkit to Allsigned\ \ debloat: Windows 10 debloater script \ exit: exits the program"
	sidemenu
	printimage
	
}
########Menu_programu##############################################################################
#Powinno znajdować się na samym dole															  #
###################################################################################################
#menu programu 
do{
	$d=0
	pause
	cls
	if ($chochek -eq "y") {
		offlinemenu
	}
	else {
		onlinemenu 
	}
	[string[]] $menu= @()
	$menu = READ-HOST ">_SAWD\"
	$menu = $menu.Split(',').Split(' ')
	$menu
	#inicjacja funkcji programu z tablicy
	switch ($menu)
	{
		"exit" {"koniec dzialania programu";$d=1;cls}
		"choman" {"**CHOCOLATE**"; hotchoco}
		"proginstaller" {"**PROGRAM_INSTALLER**"; proginstaller}
		"cholist" {"**INSTALLED PROGRAMS**"; choco list --localonly}
		"gpudrv" {"**Gpu Driver**";gpudriver}
		"debloat" {"**Debloat**";debloat}
		"fixlivemail" {"**Mai_FIX**";mailfix}
		"firewallconfig" {"**Firewall**";firewall_utl}
		7 {"**test**";testo}
		
		"polkit" {"**SecPOLKIT**"; set-ExecutionPolicy AllSigned}
	}
}while ($d -lt 1) 