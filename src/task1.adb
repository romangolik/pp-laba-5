with Ada.Text_IO;
use Ada.Text_IO;

procedure Task1 is
   size: Integer := 10000;
   SUM: Long_Integer := 0;
   numThreads: Integer := 10;

   type my_arr is array (0 .. size - 1) of Long_Integer;

   a : my_arr;
   beginMas: array (0 .. numThreads - 1) of Integer;
   endMas: array (0 .. numThreads - 1) of Integer;

   function part_sum (left : Integer; Right : Integer) return Long_Integer is
      sum : Long_Integer := 0;
   begin
      for i in left..Right loop
         sum := sum + a(i);
      end loop;
      return sum;
   end part_sum;

   procedure create_array is
   begin
      for i in a'Range loop
         a (i) := Long_Integer(i);
      end loop;
   end create_array;

   protected Buffer is
      procedure Set(V: in Long_Integer);
      entry Get(V: out Long_Integer);
   private
      Local: Long_Integer;
      Count: Integer := 0;
   end Buffer;

   protected body Buffer is
      procedure Set (V : in Long_Integer) is
      begin
         Local := V;
         Count := Count + 1;
      end Set;

      entry Get (V : out Long_Integer) when Count > 0 is
      begin
         V := Local;
         Count := Count - 1;
      end Get;
   end Buffer;

   task type my_task is
      entry start (left, RigHt : in Integer);
   end my_task;
   task body my_task is
      sum : Long_Integer := 0;
      left, RigHt : Integer;
   begin
      accept start (left, RigHt : in Integer) do
         my_task.left  := left;
         my_task.right := Right;
      end start;
      sum := part_sum(left,RigHt);
      Buffer.Set(sum);
   end my_task;

   sum00 : Long_Integer;

   tasks: array (0 .. numThreads - 1) of my_task;
begin
   create_array;

   for i in beginMas'Range loop
      beginMas(i) := size / numThreads * i;
   end loop;

   for i in endMas'First .. endMas'Last - 1 loop
      endMas(i) := beginMas(i + 1) - 1;
   end loop;

   endMas(numThreads - 1) := size - 1;

   for j in 0..numThreads - 1 loop
      tasks(j).start(beginMas(j),endMas(j));
      Buffer.Get(sum00);
      SUM := SUM + sum00;
   end loop;

   Put_Line(SUM'img & " ");
end Task1;
