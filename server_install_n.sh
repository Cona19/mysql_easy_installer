cd /opt/nvm/hyeonseok/mariadb/
rm -rf inst
cd server
#rm -rf CMakeCache.txt
BASEPATH=/opt/nvm/hyeonseok/mariadb/inst
cmake \
    -DWITH_DEBUG=1 \
    -DCMAKE_INSTALL_PREFIX=$BASEPATH \
    -DMYSQL_DATADIR=$BASEPATH/data \
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
cp ../my.cnf ./
./scripts/mysql_install_db \
    --basedir=$BASEPATH \
    --datadir=$BASEPATH/data \
    --defaults-file=my.cnf \
    --skip-name-resolve \
    --user=hyeonseok \
    --verbose
   # --force \

#./bin/mysqld_safe &
#sleep 120
#cd ../tpcc-mysql
#cd tpcc-mysql
#cd src
#make clean
#make
#cd ..
#mysqladmin -u root create tpcc100
#mysql -u root tpcc100 < create_table.sql 
#mysql -u root tpcc100 < add_fkey_idx.sql 
#./tpcc_load -h127.0.0.1 -P12943 -d tpcc100 -u root -p "" -w100
#./tpcc_start -h127.0.0.1 -P12943 -d tpcc100 -u root -p "" -w100 -c48 -r10 -l300

NUM_CONN=1

cd /opt/nvm/hyeonseok/mariadb/inst
./bin/mysqld_safe &
sleep 60
cd ../sysbench_java/
TEST_NAME=delta_100G_no_flush3_${NUM_CONN}con_128MB

mysqladmin -u root create benchmark
mysql -u root benchmark < create_table.sql
java -cp "mariadb-java-client-2.0.3.jar:." DBGen
mysqladmin -u root shutdown
rm -f ../inst/mysqld.log

cp ../my.cnf2 ../inst/my.cnf
../inst/bin/mysqld_safe &
read word

java -cp "mariadb-java-client-2.0.3.jar:." BenchClient ${NUM_CONN} 1 ${TEST_NAME}
mv ../inst/mysqld.log ./${TEST_NAME}.log
mysqladmin -u root shutdown
