#!/bin/sh
# Run ipython notebook tests

testfail=0

PYTHON_VERSION=`python -V 2>&1 | awk '{print $2}' | awk 'BEGIN { FS="." } { print $1 "." $2}'`
echo "Running tests for Python version: $PYTHON_VERSION"

dropbox_base_url="https://www.dropbox.com/s"
dropbox_base_url2="https://www.dropbox.com/scl/fi"

case $PYTHON_VERSION in
    "2.7")
        mstis=$dropbox_base_url/1x4ny0c93gvu54n/toy_mstis_1k_OPS1.nc
        mistis=$dropbox_base_url/qaeczkugwxkrdfy/toy_mistis_1k_OPS1.nc
        ;;
    "3.6")
        mstis=$dropbox_base_url/1ulzssv5p4lr61f/toy_mstis_1k_OPS1_py36.nc
        mistis=$dropbox_base_url/76981cbgxm639m3/toy_mistis_1k_OPS1_py36.nc
        ;;
    "3.7")
        mstis=$dropbox_base_url/1ulzssv5p4lr61f/toy_mstis_1k_OPS1_py36.nc
        mistis=$dropbox_base_url/76981cbgxm639m3/toy_mistis_1k_OPS1_py36.nc
        ;;
    "3.8")
        mstis=$dropbox_base_url/8rr0tt25xlm47cs/toy_mstis_1k_OPS1_py38.nc
        mistis=$dropbox_base_url/r3d5s5txbnpste0/toy_mistis_1k_OPS1_py38.nc
        ;;
    "3.9")
        mstis=$dropbox_base_url/8rr0tt25xlm47cs/toy_mstis_1k_OPS1_py38.nc
        mistis=$dropbox_base_url/r3d5s5txbnpste0/toy_mistis_1k_OPS1_py38.nc
        ;;
    "3.10")
        mstis=$dropbox_base_url/8rr0tt25xlm47cs/toy_mstis_1k_OPS1_py38.nc
        mistis=$dropbox_base_url/r3d5s5txbnpste0/toy_mistis_1k_OPS1_py38.nc
        ;;
    "3.11")
        mstis="$dropbox_base_url2/c4idtymcaqvtftigce49c/toy_mstis_1k_OPS1_py311.nc?rlkey=soa6ba7okx66439egjyuscc5l&dl=1"
        mistis="$dropbox_base_url2/s0o7br93s60q0vez88phr/toy_mistis_1k_OPS1_py311.nc?rlkey=22vdvjovt25bj4a6gh3m4vrvj&dl=1"
        ;;
    *)
        echo "Unsupported Python version: $PYTHON_VERSION"
esac

curl -OLk --http1.1 $mstis
curl -OLk --http1.1 $mistis
cp `basename $mstis` toy_mstis_1k_OPS1.nc
cp `basename $mistis` toy_mistis_1k_OPS1.nc

# from here should be the same for all versions
ls *nc
cd toy_model_mstis/
date
py.test --nbval-lax --current-env -v \
    toy_mstis_1_setup.ipynb \
    toy_mstis_2_run.ipynb \
    toy_mstis_3_analysis.ipynb \
    toy_mstis_4_repex_analysis.ipynb \
    || testfail=1

cd ../toy_model_mistis/
date
# skip toy_mistis_2_flux: not needed
py.test --nbval-lax --current-env -v \
    toy_mistis_1_setup_run.ipynb \
    toy_mistis_3_analysis.ipynb \
    || testfail=1

cd ../tests/
cp ../toy_model_mstis/mstis.nc ./
py.test --nbval --current-env \
    test_openmm_integration.ipynb \
    test_snapshot.ipynb \
    test_netcdfplus.ipynb \
    test_cv.ipynb \
    || testfail=1

cd ../misc/
cp ../toy_model_mstis/mstis.nc ./
pytest --nbval-lax --current-env tutorial_storage.ipynb || testfail=1

cd ..
rm toy_mstis_1k_OPS1.nc
rm toy_mistis_1k_OPS1.nc
if [ $testfail -eq 1 ]
then
    exit 1
fi
