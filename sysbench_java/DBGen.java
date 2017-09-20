import java.util.*;
import java.sql.*;

public class DBGen extends Common
{
	public int num_item;
	public int num_tables;
	public boolean isOracle = false;

	public DBGen()
	{ 
		this.num_item  = Integer.parseInt( props.getProperty ( "DB.TableSize" , "0" ) );
		this.num_tables  = Integer.parseInt( props.getProperty ( "DB.NumTables" , "0" ) );
		this.isOracle = props.getProperty("DB.Url", "").startsWith("jdbc:oracle");
	}

	public void generate() throws Exception
	{
		int i = 0; 
		for(i = 1 ; i <= num_tables;i++ )
		{
			generate(i);
			System.out.println( "Table bench"+i +  " is created");
		}
	}
	public void generate(int tableID) throws Exception
	{
		Connection conn = getDBConnection();
		conn.setAutoCommit( true );
		Statement stmt = conn.createStatement();
		Random r = new Random();
		for( int i = 0 ; i < num_item ; i++ )
		{
			StringBuffer buf = new StringBuffer();
			buf.append( "INSERT INTO bench" + tableID +" ( benchid, benchhot , benchdata  ) values (" );
			buf.append( i );
			buf.append( " , " ).append( r.nextInt() ).append("");
			buf.append( " , '" ).append( getString( 32, r ) ).append( "')" );
			if (!isOracle) {
				buf.append(";");
			}
			stmt.executeUpdate( buf.toString() );
		}

		stmt.close();
		conn.close();
	}

	public static void main(String[] args ) throws Exception
	{
		DBGen gen = new DBGen();
		gen.generate();
	}
}

