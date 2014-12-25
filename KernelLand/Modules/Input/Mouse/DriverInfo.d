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
 * http://bit.ly/1wIYh3A and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

module Modules.Input.Mouse.DriverInfo;

import ObjectManager;
import Modules.Input.Mouse.Main;


extern(C) const ModuleDef _DriverInfo_Input_Mouse = {
	Magic: ModuleMagic,
	Type: DeviceType.Input,
	Architecture: ModuleArch.x86_64,
	Flags: 0x00,
	Version: 0x01,
	Name: "Mouse Input Module",
	Identifier: "com.modules.Input.Mouse",
	Initialize: &Mouse.Initialize,
	Finalize: &Mouse.Finalize
};