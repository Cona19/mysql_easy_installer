import java.util.*;
import java.sql.*;
import java.io.*;

public class BenchClient extends Common implements Runnable
{
	public static int THREADS = 0;
	public static int duration = 0;
	public static int warmup = 0;
	public static int C_BUCKET = 10000;
	public static boolean is_running = true;
	public static boolean measuring = false;

	public static int NUMOFROWS = 0;
	public static int NUMTABLES = 0;

	public int u_abort = 0 ;
	public int u_succ = 0 ;

	public static long[] u_times ;
	public static long[] u_c_times ;

	Connection conn ;
	Statement stmt ;

	int th_id = 0;

	public static boolean ORACLE= false;

	public long t_a, t_b, t_c;
	public int[] tx_times;


	Random r;
	public BenchClient( int b )
	{ 
		th_id = b;
		r = new Random( System.currentTimeMillis() + b );

		//init stat variables
		u_times[th_id] = 0;
		u_c_times[th_id] = 0;

		tx_times = new int[C_BUCKET];
		for(int i = 0 ; i < C_BUCKET; i++ )
			tx_times[i] = 0;

	}

	public void run()
	{
		try
		{
			generate();
		}
		catch ( Exception e )
		{
			e.printStackTrace();
			System.exit ( 0 );
		}
	}
	public void init()  throws Exception
	{
		conn = getDBConnection();
		stmt = conn.createStatement();

		stmt.executeUpdate( "SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED" );
		conn.setAutoCommit( false );
	}

	public void generate() throws Exception
	{

		int max_key = NUMOFROWS;
		int table_id = th_id+1;

		int rand_num = 0;

		int kk = 0;
		while( is_running )
		{
			long total_time,commit_time ; 
			StringBuffer buf ;


			try
			{

				t_a =  System.nanoTime();

				buf = new StringBuffer();

				//rand_num = (rand_num + 32) % NUMOFROWS;
				//rand_num+=2;//r.nextInt( max_key );
				//rand_num = r.nextInt( max_key );

				//if ( kk % 2 == 0 )
				{


					buf = new StringBuffer();
					buf.append( "UPDATE bench").append(table_id);
					buf.append( " SET benchhot = ").append( r.nextInt() );
					buf.append(" WHERE benchid = ").append( rand_num );//.append(";");

//					rand_num = 0;//r.nextInt( max_key );
//					buf.append( "DELETE FROM bench").append(table_id);
//					buf.append(" WHERE benchid = ").append( rand_num ).append(";");
//					buf.append( "INSERT INTO bench" + table_id +" ( benchid , benchdata  ) values (" );
//					buf.append( rand_num );
//					buf.append( " , '" ).append( getString( 128, r ) ).append( "')" );

					stmt.executeUpdate( buf.toString() );
				}
				/*
				else
				{
					buf = new StringBuffer();
					buf.append( "SELECT * FROM bench").append(table_id);
					buf.append(" WHERE benchid = ").append( rand_num ).append(";");

					ResultSet rs = stmt.executeQuery( buf.toString() );
				}*/

				kk++;

				t_b =  System.nanoTime();
				conn.commit();
				t_c =  System.nanoTime();

				total_time = t_c - t_a;
				commit_time = t_c - t_b;

				if ( measuring )
				{
					total_time = total_time / 1000;
					commit_time = commit_time / 1000;
					u_succ++;
					u_times[th_id] += total_time;
					u_c_times[th_id] += commit_time;
					commit_time = commit_time / 100;
					if ( commit_time >= C_BUCKET ) commit_time = C_BUCKET-1;
					tx_times[(int)commit_time]++;
				}
			}
			catch ( Exception e )
			{
				try
				{
					e.printStackTrace();
					conn.rollback();
					System.out.println( "WOW2" );
				}
				catch ( Exception e2 )
				{
					e2.printStackTrace();
					System.exit( 0 );
					throw e2;
				}

				if ( measuring )
				{
					u_abort++;
				}
			}
		}
		try
		{
			conn.close();
		}
		catch ( Exception ex )
		{
		}
	}

	public static void main(String[] args ) throws Exception
	{
		System.out.println("START!!!");

		THREADS	= Integer.parseInt( args[0] );
		int TRIAL_NUM	= Integer.parseInt( args[1] );

		String filename = args[2];

		if (args.length > 3) {
			filename = args[3] + "/" + filename;
		}


		NUMOFROWS  = Integer.parseInt( props.getProperty ( "DB.TableSize" , "0" ) ); 
		NUMTABLES  = Integer.parseInt( props.getProperty ( "DB.NumTables" , "0" ) );

		duration = Integer.parseInt( props.getProperty ( "EXP.Duration" , "30" ) );
		warmup = Integer.parseInt( props.getProperty ( "EXP.WarmUp" , "10" ) );


		Thread[] worker = new Thread[THREADS];
		BenchClient[] gen = new BenchClient[THREADS];
		u_times = new long[THREADS];
		u_c_times = new long[THREADS];

		Thread th = new Thread( new KillThread() );
		th.start();

		for( int i = 0 ; i < THREADS ; i++ )
		{
			gen[i] = new BenchClient( i );
			gen[i].init();
			worker[i] = new Thread( gen[i] );
		}

		System.out.println("GOGOGO");
		for( int i = 0 ; i < worker.length ; i++ )
			worker[i].start();

		for( int i = 0 ; i < warmup ; i++ )
		{
			Thread.currentThread().sleep( 1000 ); //warm up
		
			long tt_b = System.currentTimeMillis();
			int count=0;
			if ( i == 0 || i == 1 ) continue;
			for( int j =0; j < worker.length ; j++ )
			{
				long c = tt_b - gen[j].t_a;

				if( c > 2000 )
					count++;
			} 
			if( count > 0 )
				System.out.println( "Oops.. processing time is long.. " + count );;
		}

		measuring = true;


		PrintWriter pw0 = new PrintWriter(new FileWriter( new File(filename+".TOTAL." +THREADS), true));

		for( int i = 0 ; i < duration/5 ; i++ )
		{
			Thread.currentThread().sleep( 5000 ); //measuring period is a time of 60 seconds.

			long tt_b = System.currentTimeMillis();
			int count=0;
			for( int j =0; j < worker.length ; j++ )
			{
					long c = tt_b - gen[j].t_b;

					if( c > 1000 )
							count++;
			}
			if( count > 0 )
					System.out.println( "Oops.. commit time is long.. " + count );;

			int u_t_succ = 0;
			int u_t_fail = 0;

			long u_t_tot_time = 0;
			long u_t_com_time = 0;


			//make summary stats
			for( int j = 0 ; j < worker.length ; j++ )
			{
				u_t_succ += gen[j].u_succ;
				u_t_fail += gen[j].u_abort;

				u_t_tot_time += u_times[j];
				u_t_com_time += u_c_times[j];
			}

			pw0.println( THREADS + "," + TRIAL_NUM  
						+ "," + u_t_succ 
						+ "," + u_t_fail 
						+ "," + u_t_tot_time 
						+ "," + u_t_com_time );
			System.out.println( THREADS + "," + TRIAL_NUM  
						+ "," + u_t_succ 
						+ "," + u_t_fail 
						+ "," + u_t_tot_time 
						+ "," + u_t_com_time );



		}
		is_running =false;

		int u_t_succ = 0;
		int u_t_fail = 0;

		long u_t_tot_time = 0;
		long u_t_com_time = 0;


			//make summary stats
		for( int i = 0 ; i < worker.length ; i++ )
		{
			u_t_succ += gen[i].u_succ;
			u_t_fail += gen[i].u_abort;

			u_t_tot_time += u_times[i];
			u_t_com_time += u_c_times[i];
		}

		System.out.println();



		pw0.println( THREADS + "," + TRIAL_NUM  
						+ "," + ( u_t_succ / duration )
						+ "," + ( u_t_fail / duration )
						+ "," + + getAvgTime( u_t_tot_time , u_t_succ ) 
						+ "," + getAvgTime( u_t_com_time , u_t_succ ) );


		System.out.println( THREADS + "," + TRIAL_NUM  
						+ "," + ( u_t_succ / duration )
						+ "," + ( u_t_fail / duration )
						+ "," + getAvgTime( u_t_tot_time , u_t_succ ) 
					+ "," + getAvgTime( u_t_com_time , u_t_succ ) );

		pw0.close();
		
		int[] tx_times = new int[C_BUCKET];
		for(int i = 0 ; i < C_BUCKET; i++ )
			tx_times[i] = 0;

		for( int i = 0 ; i < worker.length ; i++ )
		{
			for( int j = 0 ; j < C_BUCKET ; j++ )
			{
				tx_times[j] = tx_times[j] + gen[i].tx_times[j];
			}
		}
		
		for( int j = 0 ; j < C_BUCKET ; j++ )
		{
			System.out.println( j +"," + tx_times[j] );
		}


		System.exit ( 0 );
	}

	public static double getAvgTime( long a, int b )
	{
		if ( a == 0 ) return 0;
		return (double)a/(double)b;
	}
}

class KillThread implements Runnable
{
	public KillThread()
	{
	}

	public void run()
	{
		try
		{
			Thread.currentThread().sleep( 1000*BenchClient.duration * 40 );
			System.out.println("KillThread!");
			System.exit ( 0 );
		}
		catch ( Exception e )
		{
		}
	}

}

