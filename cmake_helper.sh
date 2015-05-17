if [ $# -ne 1 ]; then
    echo usage: $0 ETAPA
    exit 0
fi

if [ ! -d "build" ]; then
    echo script must be called from the compiler root folder
    exit 0
fi

cd ./build
Etapa=$1

Command="cmake"
i=1
while [ $i -lt $Etapa ]; do
    Command="$Command -DETAPA_$i=OFF"
    let i+=1
done

Command="$Command -DETAPA_$i=ON .."
echo $Command && $Command && make
cd ..
