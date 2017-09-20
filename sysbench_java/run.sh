#javac DBGen.java
#javac BenchClient.java
#mysqladmin -u root create benchmark
#mysql -u root benchmark < create_table.sql
#java -cp "mariadb-java-client-2.0.3.jar:." DBGen
java -cp "mariadb-java-client-2.0.3.jar:." BenchClient 500 1 test
