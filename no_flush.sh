cd /opt/nvm/hyeonseok/mariadb/
#rm -rf data
#cp -r data.backup data
rm -rf inst
cd server
#rm -rf CMakeCache.txt
BASEPATH=/opt/nvm/hyeonseok/mariadb/inst
cmake \
    -DWITH_DEBUG=1 \
    -DCMAKE_INSTALL_PREFIX=$BASEPATH \
    -DMYSQL_DATADIR=$BASEPATH/../data \
    -DMYSQL_UNIX_ADDR=$BASEPATH/mysql.sock \
    -DSYSCONFDIR=$BASEPATH/etc \
    -DMYSQL_TCP_PORT=12943 \
    -DMYSQL_USER=hyeonseok \
    -DDEFAULT_CHARSET=utf8 \
    -DDEFAULT_COLLATION=utf8_general_ci \
    -DWITH_EXTRA_CHARSETS=all \
    -DENABLED_LOCAL_INFILE=1 \
    -DWITH_JEMALLOC=yes \
    -DWITH_SSL=system \
    -DWITH_ZLIB=system \
    -DWITH_INNOBASE_STORAGE_ENGINE=ON \
    #-DCMAKE_CXX_FLAGS=-DHYU_HWAC \
    #-DWITH_XTRADB_STORAGE_ENGINE=ON \
    #-DWITH_ARIA_STORAGE_ENGINE=ON \
    #-DWITH_PARTITION_STORAGE_ENGINE=ON \
    #-DWITH_PERFSCHEMA_STORAGE_ENGINE=ON \
    #-DWITH_XTRADB_STORAGE_ENGINE=1 \
    #-DWITH_INNOBASE_STORAGE_ENGINE=1 \
    #-DWITH_ARCHIVE_STORAGE_ENGINE=1 \
    #-DWITH_BLACKHOLE_STORAGE_ENGINE=1
make -j
make install -j

cd ../inst/
cp ../no_flush_my.cnf ./my.cnf
#./scripts/mysql_install_db \
#    --basedir=$BASEPATH \
#    --datadir=$BASEPATH/data \
#    --defaults-file=my.cnf \
#    --skip-name-resolve \
#    --user=hyeonseok \
#    --verbose
   # --force \

if [ -z "$1" ]
then
    NUM_CONN=100
else
    NUM_CONN=$1
fi
if [ -z "$2" ]
then
    TEST_NAME=no_flush_${NUM_CONN}
else
    TEST_NAME=no_flush_$2_${NUM_CONN}
fi
if [ -z "$3" ]
then
    METHOD=random
else
    METHOD=$3
fi

cd /opt/nvm/hyeonseok/mariadb/${METHOD}_java/
../inst/bin/mysqld_safe &
sleep 600

java -cp "mariadb-java-client-2.0.3.jar:." BenchClient ${NUM_CONN} 1 ${TEST_NAME}
mv ../inst/mysqld.log ./${TEST_NAME}.log
mysqladmin -u root shutdown
