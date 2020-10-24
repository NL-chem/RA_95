#!/bin/bash

cur_dir=$(basename $(pwd))
tar_name=$(echo ""$cur_dir"_run_score.tar.gz")
echo $tar_name

if [ -d "run_score" ]
	then
		tar -cvzf $tar_name run_score
		echo "Compressed run_score to tar.gz-archive $tar_name."
		mv $tar_name ..
		echo "Moved archive one level higher."
	else
		echo "run_score directory doesn't exist!"
fi
