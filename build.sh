#!/bin/bash

OUTPUTDIR=$(PWD)/bin

if [ "$1" = "clean" ]; then
  rm -rf $OUTPUTDIR/*
  rm BinUtilsTestLibrary/BinUtilsTestLibrary/CustomViewBin.h
  rm BinUtilsTestLibrary/BinUtilsTestLibrary/CustomViewBin.m
  rm BinUtilsTestLibrary/BinUtilsTestLibrary/images.h
  rm BinUtilsTestLibrary/BinUtilsTestLibrary/images.m
  rm BinUtilsTestLibrary/BinUtilsTestLibrary/UIImage+Images.h
  rm BinUtilsTestLibrary/BinUtilsTestLibrary/UIImage+Images.m
else
  xcodebuild -workspace binutils.xcworkspace -scheme bin2c -configuration Release CONFIGURATION_BUILD_DIR=$OUTPUTDIR
  xcodebuild -workspace binutils.xcworkspace -scheme image2c -configuration Release CONFIGURATION_BUILD_DIR=$OUTPUTDIR
  rm -rf $OUTPUTDIR/*.dSYM
fi