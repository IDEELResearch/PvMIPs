#!/usr/bin/env python3
"""
launch.py
Wrapper to launch snakemake jobs on Longleaf using Slurm scheduler
"""

import os
import sys

from snakemake.utils import read_job_properties

DEFAULT_PROPERTIES = {	"threads": ("1", "-n {threads}"), "time": ("200:00:00", "-t {time}"),
			"memory": (8, "--mem={memory}g"), "log_dir": ("jobs/job%j.out", "-o {log_dir}"),
			"err_dir": ("jobs/job%j.err", "-e {err_dir}") }

os.system("mkdir -p jobs")
jobscript = sys.argv[1]
jprop = read_job_properties(jobscript)
job_properties = jprop["params"]
#os.system("echo " + str(read_job_properties(jobscript)))

# os.system("echo {} >>test.out".format(str(job_properties)))

def get_job_property(prop):

	if prop in job_properties:
		return (job_properties[prop], DEFAULT_PROPERTIES[prop][1])
	elif prop in DEFAULT_PROPERTIES:
		return DEFAULT_PROPERTIES[prop]
	else:
		return (None, None)

this_job = ""
for prop in DEFAULT_PROPERTIES.keys():
	# os.system("echo \"{}\" >>test.out".format(str(get_job_property(prop))))
	(val, fmt) = get_job_property(prop)
	if val is not None:
		# print(prop)
		# print(val)
		if val:
			this_job += " " + str(fmt).format(**{ prop: str(val) })

jobid = jprop["jobid"]
rule = jprop["rule"]
jobname = str(rule) + "." + str(jobid)
cmd = "sbatch -N 1 --job-name {jobname} {opts} {script}".format(jobname = jobname, opts = this_job, script = jobscript)
#os.system("echo \"{}\" >>test.out".format(cmd))
os.system(cmd)
