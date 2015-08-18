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

# Testing Clojure
echo -n "Testing grammar: Clojure ... "
mono himecc.exe ../clojure/Clojure.gram -o:assembly -a:public -n Hime.Grams >/dev/null
mv Clojure.dll Parsers.dll
cp ../clojure/sample.clj input.txt
mono executor.exe Hime.Grams.ClojureParser outputs
echo "OK"

# Testing C#
echo -n "Testing grammar: C# ... "
mono himecc.exe ../csharp/CSharp.gram -m:rnglr -o:assembly -a:public -n Hime.Grams >/dev/null
mv CSharp.dll Parsers.dll
cp ../csharp/sample.cs input.txt
mono executor.exe Hime.Grams.CSharpParser outputs
echo "OK"

# Testing JSON-LD
echo -n "Testing grammar: JSON-LD ... "
mono himecc.exe ../jsonld/JSONLD.gram -o:assembly -a:public -n Hime.Grams >/dev/null
mv JSONLD.dll Parsers.dll
cp ../jsonld/sample.json input.txt
mono executor.exe Hime.Grams.JSONLDParser outputs
echo "OK"

# Testing NQuads
echo -n "Testing grammar: NQuads ... "
mono himecc.exe ../nquads/NQuads.gram -o:assembly -a:public -n Hime.Grams >/dev/null
mv NQuads.dll Parsers.dll
cp ../nquads/sample.nq input.txt
mono executor.exe Hime.Grams.NQuadsParser outputs
echo "OK"

# Testing NTriples
echo -n "Testing grammar: NTriples ... "
mono himecc.exe ../ntriples/NTriples.gram -o:assembly -a:public -n Hime.Grams >/dev/null
mv NTriples.dll Parsers.dll
cp ../ntriples/sample.nt input.txt
mono executor.exe Hime.Grams.NTriplesParser outputs
echo "OK"

# Testing Turtle
echo -n "Testing grammar: Turtle ... "
mono himecc.exe ../turtle/Turtle.gram -o:assembly -a:public -n Hime.Grams >/dev/null
mv Turtle.dll Parsers.dll
cp ../turtle/sample.ttl input.txt
mono executor.exe Hime.Grams.TurtleParser outputs
echo "OK"

# Testing Functional OWL2
echo -n "Testing grammar: Functional OWL2 ... "
mono himecc.exe ../owl/FunctionalOWL2.gram -o:assembly -a:public -n Hime.Grams >/dev/null
mv FunctionalOWL2.dll Parsers.dll
cp ../owl/sample.fs input.txt
mono executor.exe Hime.Grams.FunctionalOWL2Parser outputs
echo "OK"

# Cleanup
cd ..
