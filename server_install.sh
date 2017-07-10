rm -rf inst
cd server
BASEPATH=/home/hyeonseok/mariadb/inst
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
    -DWITH_XTRADB_STORAGE_ENGINE=1 \
    #-DWITH_INNOBASE_STORAGE_ENGINE=1 \
    #-DWITH_ARCHIVE_STORAGE_ENGINE=1 \
    #-DWITH_BLACKHOLE_STORAGE_ENGINE=1
make -j
make install -j
cd ../inst/
cd inst
cp ../my.cnf ./
./scripts/mysql_install_db \
    --basedir=$BASEPATH \
    --datadir=$BASEPATH/data \
    --defaults-file=my.cnf \
    --force \
    --skip-name-resolve \
    --user=hyeonseok \
    --verbose
