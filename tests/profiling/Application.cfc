component {
    this.mappings[ "/profiling" ] = getDirectoryFromPath( getCurrentTemplatePath() );
    this.mappings[ "/qb" ] = expandPath( "/" );

    this.datasources[ "coolblog" ] = {
        class = "org.gjt.mm.mysql.Driver",
        connectionString = "jdbc:mysql://localhost:3306/coolblog?useUnicode=true&characterEncoding=UTF-8&useLegacyDatetimeCode=true",
        username = "root",
        password = "encrypted:58a6d180adc640d2364bb235a4003f49b9f133e14626fb0d"
    };

    this.datasource = "coolblog";
}