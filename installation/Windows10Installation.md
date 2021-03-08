<h1><p align="center">Experimental Windows 10 Installation Procedure</p></h1>

<h3>Install a Linux Subsystem with Graphical Support</h3>

1) Install [WSL 2](https://docs.microsoft.com/en-us/windows/wsl/install-win10) (the Windows Subsystem for Linux "2").

    - Users on the Windows "Insider Build" can simply execute `wsl --install` in a PowerShell prompt, apparently.
    
2) Install [GWSL](https://www.microsoft.com/en-ca/p/gwsl/9nl6kd1h33v3?activetab=pivot:overviewtab) and [Debian](https://www.microsoft.com/en-ca/p/debian/9msvkqc78pk6?activetab=pivot:overviewtab) from the Windows Store.

    - GWSL is a utility providing an easy way to launch your graphical Linux applications, and it provides an XServer on Windows, which is required to run SLiMgui.
    - **Open Debian once before proceeding to Step 3; you'll create a user account (which will automatically have administrator privileges) in Debian.**
    	- This is also the step wherein you'd discover an error _if_ you failed to run the Linux Kernel update from Microsoft (Step Four of the _WSL Manual Installation_ procedure).

3) Open the GWSL Dashboard by left-clicking on its system tray icon (press the primary mouse button).

    a) Click "Linux Shell" to open a terminal that will be used later.
	
4) Select the _GWSL Distro Tools_ menu option in the GWSL Dashboard.
  
	  a) Under the 'Configure Debian' header, ensure the first line reads "Display is set to Auto-export".
    
5) Right-click the GWSL system tray icon (press the secondary mouse button).

	a) Select the "XServer Profiles" menu option.
  
	b) Select "Add A Profile".
  
6) Type a descriptive profile name, such as "OpenGL" or "SLiMgui OpenGL".

7) Copy this information into the "VcXsrv Flags:" text field:
	`-nowgl -compositewm -multiwindow -clipboard -primary`

<h3>Install SLiMgui</h3>

1) Update Debian in the Debian terminal window opened in _Step 3-a_:
    
    ```bash
    sudo apt update && sudo apt upgrade
    ```

2) Install the dependencies for SLiMgui:
	  
    ```bash
    sudo apt install curl unzip g++ cmake qt5-qmake qt5-default xdg-utils firefox-esr
    ```

3) In a Debian terminal, execute this piped command:

    ```bash
    curl https://raw.githubusercontent.com/MesserLab/SLiM-Extras/master/installation/DebianUbuntuInstall.sh | sudo bash -s
    ```

4) SLiMgui can be opened by selecting it within the "Linux Apps" entry of the GWSL Dashboard.

    - A desktop shortcut can also be created for SLiMgui by using the _Shortcut Creator_ tool in the GWSL Dashboard.
