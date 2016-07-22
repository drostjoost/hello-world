declare
  type t_lines_tab is table of varchar2(4000) index by pls_integer;
  r_lines t_lines_tab;
  out_lines t_lines_tab;
  cursor c_lines(b_type varchar2, b_name varchar2)
  is
    select text from user_source
     where type = b_type
       and name = b_name
     ORDER by line asc;
  l_line varchar2(4000);
  l_line1 varchar2(4000);
  l_line_out varchar2(4000);
  is_block boolean;
  m  pls_integer;
begin
  is_block := false;
  open c_lines('PACKAGE','PKG_LOG');
  fetch c_lines bulk collect into r_lines;
  close c_lines;
  for i in 1..r_lines.count loop
    dbms_output.put(lpad(i,4,'0')||':'||r_lines(i));
  end loop;
  dbms_output.put_line(chr(10));
  --
  for i in 1..r_lines.count loop
    l_line := ltrim(r_lines(i));
    if substr(l_line,1,3) in ('---','/**') then
      --1. find header for this block of comments
      for j in 1..5 loop
        dbms_output.put_line('j='||j);
        exit when i-j = 0;
        if instr(upper(r_lines(i-j)),'PACKAGE')>0 then
          --
          l_line_out := r_lines(i-j);
          out_lines(out_lines.count+1) := '#'||substr(l_line_out,1,instr(l_line_out,' ',1,2));
        end if;
      end loop;
      out_lines(out_lines.count+1) := substr(l_line,4);
      --2. find lines belonging to this block
      is_block := true;
      m := 1;
      if substr(l_line,1,3) = '---' then
        loop
          l_line1 := ltrim(r_lines(i+m));
          --check for continuation of comment blcok
          if substr(l_line1,1,2) = '--' then
            out_lines(out_lines.count+1) := substr(l_line1,3);
          else
            exit;
          end if;
          m := m + 1;
        end loop;
      end if;
    end if;
    if substr(l_line,1,2) = '--' then
      null;
    end if;
  end loop;
  dbms_output.put_line(l_line_out||chr(10));
  for i in 1..out_lines.count loop
    dbms_output.put(out_lines(i));
  end loop;
  dbms_output.put_line(chr(10));
end;
/

  
select *
from user_source
where type in ('PACKAGE','PACKAGE BODY')
  AND name = 'PKG_LOG';
  
