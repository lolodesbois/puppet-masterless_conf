class masterless_conf() {

    # install GIT from distro packages
    package { 'git':
        ensure => installed
    }
    
    # Install bindfs to create shared folder /home/shared mount using bindfs on /media/sharedRessources with user perm (only if user is in mediashare group)

#class bindfs {
    package { 'bindfs':
        ensure => installed
    }
    
    group { "mediashare":
        ensure => present
        #gid    => 1000
    }
    
    file { 'sharedhomefolder':
        path => '/home/shared/',
        ensure => 'directory',
        owner => 'root',
        group => 'root'
    }
    file { 'mediasharedresourcesfolder':
        path => '/media/sharedResources/',
        ensure => 'directory',
        owner => 'root',
        group => 'root'
    }
    
    mount {'/media/sharedResources':
        device   => 'UUID=661E1BCF1E1B96E1',
        fstype   => 'ntfs-3g',
#        options  => 'rw,user,auto,gid=0,uid=0,nls=utf8,umask=002',
        options  => 'rw,user,auto,gid=0,uid=0,nls=utf8,umask=002,fmask=0177,dmask=0077',
        remounts => false,
        atboot   => true,
        ensure   => mounted,
        require  => File['mediasharedresourcesfolder']
    }
        
    mount {'/home/shared':
        device   => 'bindfs#/media/sharedResources',
        fstype   => 'fuse',
        options  => "rw,perms=774,create-with-perms=o-rwx,create-for-group=mediashare,mirror=@mediashare",
        remounts => false,
        atboot   => true,
        ensure   => mounted,
        require  => [File['sharedhomefolder'],Mount['/media/sharedResources']]
    }

    #}

    # install Chromium
    package { 'chromium': 
        ensure => installed
    }
    
    # install VIM
    package { 'vim':
        ensure => installed  
    }
    
    # install nginx
    #class { 'nginx':
    #}


    # install php 5 resources
    package { 'php5':
       ensure => installed
    }
    package { 'php5-fpm':
       ensure => installed
    }
    package { 'php5-gd':
       ensure => installed
    }
    package { 'php5-imagick':
       ensure => installed
    }
    package { 'php5-json':
       ensure => installed
    }
    package { 'php5-mysql':
       ensure => installed
    }

    #http://download.virtualbox.org/virtualbox/5.0.14/virtualbox-5.0_5.0.14-105127~Ubuntu~wily_amd64.deb
    # Install Virtualbox
    class { 'virtualbox':
    	manage_repo    => false,
    	version		=> '5.0',
#    	package_name   => 'virtualbox-5.0',
#    	package_ensure => '5.0.14-105127'
    }

    virtualbox::extpack { 'Oracle_VM_VirtualBox_Extension_Pack':
    	ensure       => present,
    	source       => 'http://download.virtualbox.org/virtualbox/5.0.14/Oracle_VM_VirtualBox_Extension_Pack-5.0.14-105127.vbox-extpack',		
    	checksum_string  => 'a1c1794967ddf9342ca1780e4121e1f2',
    	follow_redirects => true,
    }

    # install latest oracle JDK
    class { 'jdk_oracle': 
        version      => "8",
        default_java => true
    }

    # TODO add jre tool to path using profile.d
    #$javahome='/opt/jdk1.8.0_11'
    
    # set JAVA_HOME at system level (profile.d) using template
    #file { '/etc/profile.d/java.sh':
    #    ensure  => file,
    #    content => epp('javascript_training_ide/java.sh.epp', {'java_home' => $javahome}),
    #    require => Class['jdk_oracle']
    #}
 
    # Install nodeJS
    class { 'nodejs':
        version => 'latest',
        make_install => false
    }
    
    # install globally yarn using npm to replace ...npm 
    package { 'yarn':
        ensure   => 'present',
        provider => 'npm',
    }
    
    # intall atom.io ide and plugins
    archive { '/tmp/atom-amd64.deb':
        ensure        => present,
        extract       => false,
        source        => 'https://github.com/atom/atom/releases/download/v1.12.7/atom-amd64.deb',
        creates       => '/tmp/atom-amd64.deb',
        cleanup       => false,
    }
    ->
    package { "atom-amd64":
        provider => dpkg,
        ensure   => latest,
        source   => "/tmp/atom-amd64.deb"
    }
    ->
    exec { "auto-indent":
        path    => ["/usr/bin", "/usr/sbin", "/bin"],
        command => "apm install auto-indent"
    }
    ->
    exec { "git-plus":
        path    => ["/usr/bin", "/usr/sbin", "/bin"],
        command => "apm install git-plus"
    }
    ->
    exec { "linter":
        path    => ["/usr/bin", "/usr/sbin", "/bin"],
        command => "apm install linter"
    }
    ->
    exec { "linter-eslint":
        path    => ["/usr/bin", "/usr/sbin", "/bin"],
        command => "apm install linter-eslint"
    }   
    ->
    exec { "seti-icons":
        path    => ["/usr/bin", "/usr/sbin", "/bin"],
        command => "apm install seti-icons"
    }
}

