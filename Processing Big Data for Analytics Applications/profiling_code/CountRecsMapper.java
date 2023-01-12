import java.io.IOException;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;
public class CountRecsMapper
 extends Mapper<Object, Text, Text, IntWritable> {

 @Override
 public void map(Object key, Text value, Context context)
 throws IOException, InterruptedException {
    Text output = new Text("Number of records: ");
    int o = 1;
    IntWritable one = new IntWritable(o);
    context.write(output,one);

    }
   }