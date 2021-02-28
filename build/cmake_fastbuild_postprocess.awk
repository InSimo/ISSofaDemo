# This awk script postprocess the generated fbuild.bff file in order to:
# - capture all environment variables so that the build can then be started from outside visual
#   studio IDE or command prompt.
# - enable AllowDBMigration_Experimental in order not to rebuild everything after each cmake run
#   (/!\ need an update to our current fastbuild version for this to work)
# - customize the fbuild command line used by Visual Studio by adding either:
#   - the environment variable FASTBUILD_COMMAND_ARGS if it exists
#   - or "-j7 -fastcancel" as a reasonable default (to not overload the RAM if you have >8 cores
#     and enable quick build cancellation so you can restart a build quicker after fixing an issue.

BEGIN {
  # we can't run from cygwin/msys env as the env variables won't work outside of it
  if (ENVIRON["TEMP"] == "/tmp") exit 1;
  if ("FASTBUILD_COMMAND_ARGS" in ENVIRON) fbuildargs = "^$(FASTBUILD_COMMAND_ARGS)";
  else fbuildargs = "-j7 -fastcancel";
}
# skip output of earlier runs of the script
/^;BEGIN-SCRIPT/,/^;END-SCRIPT/ { next }
/^Settings$/ {
  # print 'Settings' and '{' and set current record to '}'
  print; getline; print;
  print ";BEGIN-SCRIPT"
  # Do not rebuild all after update of the bff file (EXPERIMENTAL)
  print "	.AllowDBMigration_Experimental = true";
  # Capture current environment so fbuild can be run from anywhere to build
  # (and no longer rebuild when switching to Visual Studio because if mismatch in LIB)
  print "	.Environment = \n	{";
  n = asorti(ENVIRON, vars);
  for (i = 1; i <= n; i++) {
    a = vars[i];
    v = ENVIRON[a];
    gsub(/\$/,"^$",v);
    if (a ~ /^(!|PROMPT|AWK|TERM|FASTBUILD_COMMAND_ARGS|[a-u])/) continue;
    # It would be much better to only provide visual studio variables and keep
    # the rest of the environment variables from where we run fbuild, but that's not supported
    #if (a ~ /^(DevEnv|Framework|INCLUDE|LIB|NETFX|Path|Platform|UCRT|UniversalCRT|VC|VisualStudio|VS|Windows)/)
    {
      print "		'"a"="v"',";
    }
  }
  print "	}";
  print ";END-SCRIPT"
  next
}
# customise (re)build commands:
# - force a lower number of concurrent compiles (7 threads barely fit in 16GB of RAM)
# - enable fastcancel (EXPERIMENTAL) to start a new build faster when the previous one is still running
$1~/\.Project.*Command/ { gsub( /; fbuild .*-vs/, "; fbuild " fbuildargs " -vs"); }
{ print }
