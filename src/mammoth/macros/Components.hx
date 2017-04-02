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

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

class Components {
    private static function isPublic(field:Field):Bool {
        for(access in field.access) switch(access) {
            case APublic: return true;
            case _:
        }
        return false;
    }

    macro public static function exportComponent():Array<Field> {
        var fields:Array<Field> = Context.getBuildFields();
        var cls:ClassType = Context.getLocalClass().get();

        // early exit if we want to skip this component
        if(cls.meta.has('ignoreAutoMap')) {
            return fields;
        }

        // load the existing map if it exists
        var map:Dynamic = {};
        if(sys.FileSystem.exists('component_map.json'))
            map = haxe.Json.parse(sys.io.File.getContent('component_map.json'));

        var componentMap:Array<Dynamic> = new Array<Dynamic>();
        for(field in fields) {
            if(!isPublic(field)) continue;

            // only do variables
            var type:String = switch(field.kind) {
                case FVar(t, e): {
                    switch(t) {
                        case TPath(p): {
                            switch(p.name) {
                                case 'Float': 'float';
                                case 'String': 'string';
                                case 'Int': 'int';
                                case 'Bool': 'bool';
                                case 'Vec2': 'vec2';
                                case 'Vec3': 'vec3';
                                case 'Vec4': 'vec4';
                                case 'Colour': 'colour';
                                case _: null;
                            }
                        }
                        case _: null;
                    }
                }
                case _: null;
            }
            if(type == null) continue;

            var prop:Dynamic = {};
            Reflect.setField(prop, "name", field.name);
            Reflect.setField(prop, "type", type);

            componentMap.push(prop);
        }
        
        Reflect.setField(map, cls.name, componentMap);
        if(!sys.FileSystem.exists('component_map.json'))
            Sys.println('[\033[33mmammoth\033[0m] created map file \033[32mcomponent_map.json\033[0m!');
        sys.io.File.saveContent('component_map.json',
            haxe.Json.stringify(map, null, "  ")
        );
        return fields;
    }
}