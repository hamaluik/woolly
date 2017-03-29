/*
 * Copyright (c) 2017 Kenton Hamaluik
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *     http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/
package mammoth.macros;

#if sys
import haxe.macro.Context;
import haxe.macro.Expr;
import Sys;
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;

class Assets {
    public static function mkdirIfNotExists(dir:String):Void {
        // convert to filesystem-native slashes
        dir = Path.join(dir.split('/'));
        if(!FileSystem.exists(dir)) {
            FileSystem.createDirectory(dir);
            Sys.println('[\033[33mmammoth\033[0m] created directory \033[32m${dir}\033[0m!');
        }
    }

    public static function copy(source:String, target:String):Void {
        if(FileSystem.isDirectory(source))
            throw 'Cannot copy ${source}, it is a directory! Use `copyDir` instead!';
        if(FileSystem.exists(target) && FileSystem.isDirectory(target))
            throw 'Cannot copy ${source} to ${target}, as ${target} is a directory!';

        // convert to the filesystem-native slashes
        source = Path.join(source.split('/'));
        target = Path.join(target.split('/'));

        File.copy(source, target);
        Sys.println('[\033[33mmammoth\033[0m] copied \033[32m${source}\033[0m to \033[36m${target}\033[0m');
    }

    public static function copyDir(sourceDir:String, targetDir:String):Int {
        var numCopied:Int = 0;

        if(!FileSystem.exists(targetDir))
            FileSystem.createDirectory(targetDir);

        for(entry in FileSystem.readDirectory(sourceDir)) {
            // skip unwanted files
            if(['.DS_Store'].indexOf(entry) != -1) continue;

            var srcFile:String = Path.join([sourceDir, entry]);
            var dstFile:String = Path.join([targetDir, entry]);

            if(FileSystem.isDirectory(srcFile))
                numCopied += copyDir(srcFile, dstFile);
            else {
                copy(srcFile, dstFile);
                numCopied++;
            }
        }
        return numCopied;
    }

    public static function buildAssetList():Array<Field> {
        var fields:Array<Field> = Context.getBuildFields();

        var assetSrcFolder = Path.join([Sys.getCwd(), "src", "resources", "assets"]);
        var files:Array<String> = listFiles(assetSrcFolder);

        // add the fields to the class
        for(file in files) {
            var relativePath:String = file.substr(assetSrcFolder.length + 1);
            var name:String = "asset___" + relativePath.split("/").join("___").split("-").join("_").split(".").join("__");
            relativePath = "assets/" + relativePath;

            fields.push({
                name: name,
                doc: relativePath,
                access: [Access.APublic, Access.AStatic, Access.AInline],
                pos: Context.currentPos(),
                kind: FieldType.FVar(macro: String, macro $v{relativePath})
            });
        }

        return fields;
    }

    public static function listFiles(directory:String):Array<String> {
        var files:Array<String> = new Array<String>();
        for(f in FileSystem.readDirectory(directory)) {
            var file:String = Path.join([directory, f]);
            if(FileSystem.isDirectory(file))
                files = files.concat(listFiles(directory));
            else
                files.push(file);
        }
        return files;
    }
}
#end