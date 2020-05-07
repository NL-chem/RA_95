#!/bin/bash

cur_dir=$(basename $(pwd))
tar_name=$(echo ""$cur_dir"_run.tar.gz")
echo $tar_name

if [ -d "run" ]
	then
		tar -cvzf $tar_name run
		echo "Compressed run to tar.gz-archive $tar_name."
		mv $tar_name ..
		echo "Moved archive one level higher."
	else
		echo "run directory doesn't exist!"
fi
