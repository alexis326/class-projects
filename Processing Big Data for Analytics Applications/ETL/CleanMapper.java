import java.io.IOException;
import java.util.Arrays;
import javax.naming.Context;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;
public class CleanMapper
 extends Mapper<Object, Text, Text, IntWritable> {

 @Override
 public void map(Object key, Text value, Context context)
 throws IOException, InterruptedException {

    String[] line = (value.toString()).split(",");
    IntWritable one = new IntWritable(1);
    Text new_write_line = new Text();

    if (line.length == 35){
        if (line[1].matches("^[A-Za-z ]*$") && line[2].matches("^[A-Za-z ]*$")  && line[17].matches("^[A-Za-z- ]*$") && line[18].matches("^[A-Za-z ]*$") && line[1] != "Puerto Rico") 
        {
	 String joined_line = String.join(",", line);
	 new_write_line.set(joined_line);
         context.write(new_write_line, one);
        }
    };


    }
   }