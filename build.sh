#!/bin/sh

DIRECTORY=target

# Clone and build the runtime
if [ ! -d "$DIRECTORY" ]; then
  mkdir $DIRECTORY
fi
cd $DIRECTORY
if [ ! -d "hime" ]; then
  # repo does not exist => clone
  echo "Cloning hime ..."
  hg clone https://bitbucket.org/laurentw/hime >/dev/null
  cd hime
else
  # the repo exists => pull changes and clean
  echo "Pulling new changes ..."
  cd hime
  hg pull -u >/dev/null
  xbuild /p:Configuration=Release /t:Clean runtimes/net/Hime.Redist.csproj >/dev/null
  xbuild /p:Configuration=Release /t:Clean core/Hime.SDK.csproj >/dev/null
  xbuild /p:Configuration=Release /t:Clean cli/net/HimeCC.csproj >/dev/null
  xbuild /p:Configuration=Release /t:Clean tests/net/Tests.Executor.csproj >/dev/null
fi
echo "Building hime ..."
xbuild /p:Configuration=Release runtimes/net/Hime.Redist.csproj >/dev/null
xbuild /p:Configuration=Release core/Hime.SDK.csproj >/dev/null
xbuild /p:Configuration=Release cli/net/HimeCC.csproj >/dev/null
xbuild /p:Configuration=Release tests/net/Tests.Executor.csproj >/dev/null
cd ..
cp hime/runtimes/net/bin/Release/Hime.Redist.dll Hime.Redist.dll
cp hime/core/bin/Release/Hime.CentralDogma.dll Hime.CentralDogma.dll
cp hime/cli/net/bin/Release/himecc.exe himecc.exe
cp hime/tests/net/bin/Release/Tests.Executor.exe executor.exe

# Prepare an empty expected output file
rm -f expected.txt
touch expected.txt

# Testing EBNF
echo -n "Testing grammar: EBNF ... "
mono himecc.exe ../ebnf/EBNF.gram -o:assembly -a:public -n Hime.Grams >/dev/null
mv EBNF.dll Parsers.dll
cp ../ebnf/sample.txt input.txt
mono executor.exe Hime.Grams.EBNFParser outputs
echo "OK"

# Testing Hime
echo -n "Testing grammar: Hime ... "
mono himecc.exe ../hime/Hime.gram -o:assembly -a:public -n Hime.Grams >/dev/null
mv Hime.dll Parsers.dll
cp ../hime/Hime.gram input.txt
mono executor.exe Hime.Grams.HimeParser outputs
echo "OK"

# Testing Alf
echo -n "Testing grammar: Alf ... "
mono himecc.exe ../alf/Alf.gram -m:rnglr -o:assembly -a:public -n Hime.Grams >/dev/null
mv Alf.dll Parsers.dll
cp ../alf/sample.txt input.txt
mono executor.exe Hime.Grams.AlfParser outputs
echo "OK"

# Cleanup
cd ..
