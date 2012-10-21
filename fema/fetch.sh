#!/bin/bash

mkdir download
cd download
curl "$(cat ../data.url)" > fema.xls
cd ../
