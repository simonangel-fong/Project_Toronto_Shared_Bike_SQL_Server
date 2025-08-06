CREATE DATABASE toronto_shared_bike
ON PRIMARY 
(
    NAME = 'toronto_shared_bike',
    FILENAME = '/var/opt/mssql/data/toronto_shared_bike/toronto_shared_bike.mdf',
    SIZE = 100MB,
    FILEGROWTH = 20MB
)
LOG ON
(
    NAME = 'toronto_shared_bike_Log',
    FILENAME = '/var/opt/mssql/data/toronto_shared_bike/toronto_shared_bike_Log.ldf',
    SIZE = 50MB,
    FILEGROWTH = 10MB
);
