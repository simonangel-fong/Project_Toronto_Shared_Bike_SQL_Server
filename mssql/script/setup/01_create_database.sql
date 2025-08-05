CREATE DATABASE TorontoSharedBikeDB
ON PRIMARY 
(
    NAME = 'TorontoSharedBike_Data',
    FILENAME = '/var/opt/mssql/data/TorontoSharedBike/TorontoSharedBike_Data.mdf',
    SIZE = 100MB,
    FILEGROWTH = 20MB
)
LOG ON
(
    NAME = 'TorontoSharedBike_Log',
    FILENAME = '/var/opt/mssql/data/TorontoSharedBike/TorontoSharedBike_Log.ldf',
    SIZE = 50MB,
    FILEGROWTH = 10MB
);
