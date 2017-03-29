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
package mammoth;

import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.EnumFlags;

/**
 * Generally not used by user-facing code, this `enum` is for tracking
 * the type of log that is being written.
 */
enum LogFunctions {
	/**
	 * Show-stopping error
	 */
	Fatal;

	/**
	 * Crashes / exceptions
	 */
	Error;

	/**
	 * Incorrect behaviour but can continue
	 */
	Warn;

	/**
	 * Indicates correct behaviour
	 */
	Info;

	/**
	 * Behind-the-scenes poking around
	 */
	Debug;
}

class Log {
    private function new() {}

	public static function log(v:Dynamic, func:LogFunctions, ?pos:haxe.PosInfos):Void {
		#if js
            var console:js.html.Console = js.Browser.console;
			switch(func) {
				case Fatal: {
					console.error(pos.fileName + ':' + pos.lineNumber, v);
					throw new String('FATAL EXCEPTION: ' + pos.fileName + ':' + pos.lineNumber + ': ' + v.toString());
				}
				case Error: console.error(pos.fileName + ':' + pos.lineNumber, v);
				case Warn: console.warn(pos.fileName + ':' + pos.lineNumber, v);
				case Info: console.info(pos.fileName + ':' + pos.lineNumber, v);
				case Debug: console.debug(pos.fileName + ':' + pos.lineNumber, v);
				default: console.log(pos.fileName + ':' + pos.lineNumber, v);
			}
		#else
			trace(v, pos);
		#end
	}

	/**
	 * Use for show-stopping errors
	 * @param value the message / object to log
	 */
	macro public static function fatal(value:Dynamic):Expr {
		#if log_fatal
			return macro @:pos(Context.currentPos()) mammoth.Log.log($value, mammoth.Log.LogFunctions.Fatal);
		#else
			return macro null;
		#end
	}


	/**
	 * Use for crashes and exceptions, and any other errors that aren't
	 * necessarily show-stopping but require intervention.
	 * @param value the message / object to log
	 */
	macro public static function error(value:Dynamic):Expr {
		#if log_error
			return macro @:pos(Context.currentPos()) mammoth.Log.log($value, mammoth.Log.LogFunctions.Error);
		#else
			return macro null;
		#end
	}

	/**
	 * Use for indicating incorrect behaviour (but execution can be continued).
	 * @param value the message / object to log
	 */
	macro public static function warning(value:Dynamic):Expr {
		#if log_warning
			return macro @:pos(Context.currentPos()) mammoth.Log.log($value, mammoth.Log.LogFunctions.Warn);
		#else
			return macro null;
		#end
	}

	/**
	 * Use to indicate normal behaviour
	 * @param value the message / object to log
	 */
	macro public static function info(value:Dynamic):Expr {
		#if log_info
			return macro @:pos(Context.currentPos()) mammoth.Log.log($value, mammoth.Log.LogFunctions.Info);
		#else
			return macro null;
		#end
	}

	/**
	 * Use for logging behind-the-scenes information.
	 * @param value the message / object to log
	 */
	macro public static function debug(value:Dynamic):Expr {
		#if debug
			return macro @:pos(Context.currentPos()) mammoth.Log.log($value, mammoth.Log.LogFunctions.Debug);
		#else
			return macro null;
		#end
	}
}