/**
 * Copyright (c) 2014 Trinix Foundation. All rights reserved.
 * 
 * This file is part of Trinix Operating System and is released under Trinix 
 * Public Source Licence Version 0.1 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 * 
 * You may obtain a copy of the License at
 * http://pastebin.com/raw.php?i=ADVe2Pc7 and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

module Architecture.Main;

import Core;
import Architecture;
import ObjectManager;


abstract final class Arch {
	static void Main(uint magic, void* info) {
		Log.WriteJSON("{");
		Log.WriteJSON("name", "multiboot2");
		Log.WriteJSON("value", "{");
		Multiboot.ParseHeader(magic, info);
		Log.WriteJSON("}");
		Log.WriteJSON("}");

		Log.WriteJSON("{");
		Log.WriteJSON("name", "CPU");
		Log.WriteJSON("value", "[");
		CPU.Initialize();
		CPU.Install();
		Log.WriteJSON("]");
		Log.WriteJSON("}");
	}
}