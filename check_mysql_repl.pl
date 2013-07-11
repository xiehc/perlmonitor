#!/usr/bin/perl
use DBI;

$num=$#ARGV;
#print "first $#ARGV  ";
#print "num: $num  ";
if ($num != 0)
{
print "Critical, Argument ERROR!\n";
exit(2) ;
}

$var=`date "+%s"`;
chomp($var);
@host_port = split(/,/, $ARGV[0]);
@m_host_port = split(/:/, @host_port[0]);
$mhost = @m_host_port[0];
$mport = @m_host_port[1];


@s_host_port = split(/:/, @host_port[1]);
$shost = @s_host_port[0];
$sport = @s_host_port[1];

#print "master Host: $mhost \n ";
#print "master Port: $mport \n ";
#print "slave Host: $shost \n ";
#print "slave Port: $sport \n ";



$dbname="mid_repl";
$user="repl_monitor";
$pass="monitor_mysql";
#print "value $var : ";
#print "master value $mhost !!!";
#print "slave value $shost !!!";

#check 


#Check MYSQL status
my $mthis_dbh = &MysqlConnect( $mhost, $mport, $user, $pass, $dbname);

if( !$mthis_dbh ){
#print "Critical,MPGSQL $mhost Connection Error::$DBI::errstr\n";
print "Critical, Master_MySQL $mhost : $mport Connection Error!\n";
exit(2);
}

my $mresd = &MysqlDo( $mthis_dbh, "update replication_test set stat=$var");
if (! $mresd){
print "Critical, Master_Mysql $mhost : $mport UPDATE Error!\n";
exit(2);
}

my $mresq = &MysqlQuery( $mthis_dbh, "SELECT stat FROM replication_test" );
#print "Master var: $mresq->{'stat'} ,";
if ( $var == $mresq->{'stat'} )
{
#print "Master var: $mresq->{'stat'} ";
#print "OK, MPGSQL $mhost SET/GET ok!\n";
$mpgsql = 1; 
}else
{
print "Critical, Master_Mysql $mhost : $mport SET/GET ERROR!\n";
exit(2);
}

#sleep 5sec
sleep(2);

#Check Repl status
my $sthis_dbh = &MysqlConnect( $shost, $sport, $user, $pass, $dbname);
if( !$sthis_dbh ){
#print "Critical,SPGSQL $shost Connection Error::$DBI::errstr\n";
print "Critical, Slave_MySQL $shost : $sport Connection Error!\n";
exit(2);
}

my $sresq = &MysqlQuery( $sthis_dbh, "SELECT stat FROM replication_test" );
#print "Slave var: $sresq->{'stat'} ,";
if ( $var == $sresq->{'stat'} )
{
#print "$var | $Sresq->{'stat'} \n";
#print "Slave var: $sresq->{'stat'} ";
#print "OK, Repl status OK!\n";
$repl = 1;
}else
{
print "Critical,Master var: $mresq->{'stat'},Slave var: $sresq->{'stat'}, $shost : $sport repl status ERROR!\n";
exit(2);
}

if ( $mpgsql && $repl){
print " OK, MYSQL $mhost : $mport SET/GET OK.Repl $shost : $sport status OK!\n";
exit(0);
}


#Function

sub MysqlConnect($$$$$) {
    my ( $host, $port, $user, $pass, $dbname ) = @_;
    my $dsn = "DBI:mysql:database=$dbname;host=$host;port=$port";
    return DBI->connect( $dsn, $user, $pass, {PrintError => 0,RaiseError => 0} );
}

sub MysqlDo($$) {
    my ( $dbh, $query ) = @_;
    my $re = $dbh->do($query);
    return undef unless ($re);
    return $re;
}

sub MysqlQuery($$) {
    my ( $dbh, $query ) = @_;
    my $sth = $dbh->prepare($query);
    my $res = $sth->execute();
    return undef unless ($res);
    my $row = $sth->fetchrow_hashref;
    $sth->finish;
    return $row;
}

