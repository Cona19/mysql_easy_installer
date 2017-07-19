rm -rf inst
cd server
#rm -rf CMakeCache.txt
BASEPATH=/opt/nvm/hyeonseok/mariadb/inst
cmake \
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
#    --force \

./bin/mysqld_safe &

sleep 60
cd ../tpcc-mysql
cd src
make clean
make
cd ..
mysqladmin -u root create tpcc10
mysql -u root tpcc10 < create_table.sql 
mysql -u root tpcc10 < add_fkey_idx.sql 
./tpcc_load -h127.0.0.1 -P12943 -d tpcc10 -u root -p "" -w1
./tpcc_start -h127.0.0.1 -P12943 -d tpcc10 -u root -p "" -w1 -c16 -r10 -l10
mysqladmin -u root shutdown
