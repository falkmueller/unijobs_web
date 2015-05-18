<?php

FileSystem::makeDir("public");
FileSystem::makeDir("public/js");
FileSystem::makeDir("public/css");
FileSystem::makeDir("public/fonts");
FileSystem::copy(__dir__."/vendor/jquery/jquery", __dir__."/public/js");
FileSystem::copy(__dir__."/vendor/twitter/bootstrap/js", __dir__."/public/js");
FileSystem::copy(__dir__."/vendor/twitter/bootstrap/css", __dir__."/public/css");
FileSystem::copy(__dir__."/vendor/twitter/bootstrap/fonts", __dir__."/public/fonts");
FileSystem::copy(__dir__."/vendor/angularjs/angular", __dir__."/public/js");
FileSystem::copy(__dir__."/vendor/angularjs/angular-route", __dir__."/public/js");

class FileSystem {
    public static function makeDir($path)
    {
        echo "Create Folder: $path; ".PHP_EOL;
         return is_dir($path) || mkdir($path);
    }
    
    public static function copy($source, $dest){
        if(is_dir($source)) {
            $dir_handle=opendir($source);
            while($file=readdir($dir_handle)){
                if($file!="." && $file!=".."){
                    if(is_dir($source."/".$file)){
                        if(!is_dir($dest."/".$file)){
                            mkdir($dest."/".$file);
                        }
                        $this::copy($source."/".$file, $dest."/".$file);
                    } else {
                         echo "Copy File: $source/$file to $dest; ".PHP_EOL;
                        copy($source."/".$file, $dest."/".$file);
                    }
                }
            }
            closedir($dir_handle);
        } else {
            echo "Copy File: $source to $dest; ".PHP_EOL;
            copy($source, $dest);
        }
    }
}

