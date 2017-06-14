//
//  generate.h
//  voronoi-gen
//
//  Created by Amit Shah on 2017-06-13.
//  Copyright © 2017 Amit Shah. All rights reserved.
//


#pragma once
#if UNITY_METRO
#define EXPORT_API __declspec(dllexport) __stdcall
#elif UNITY_WIN
#define EXPORT_API __declspec(dllexport)
#else
#define EXPORT_API
#endif

