## Creating A Database
DROP DATABASE IF EXISTS employees;
CREATE DATABASE IF NOT EXISTS employees;

USE employees;

SELECT 'CREATING DATABASE STRUCTURE' as 'INFO';

DROP TABLE IF EXISTS dept_emp,
                     dept_manager,
                     titles,
                     salaries, 
                     employees, 
                     departments;
                     
CREATE TABLE employees (
    emp_no INT NOT NULL,
    birth_date DATE NOT NULL,
    first_name VARCHAR(14) NOT NULL,
    last_name VARCHAR(16) NOT NULL,
    gender ENUM('M', 'F') NOT NULL,
    hire_date DATE NOT NULL,
    PRIMARY KEY (emp_no)
);

CREATE TABLE departments (
    dept_no     CHAR(4)         NOT NULL,
    dept_name   VARCHAR(40)     NOT NULL,
    PRIMARY KEY (dept_no),
    UNIQUE  KEY (dept_name)
);

CREATE TABLE dept_manager (
   emp_no       INT             NOT NULL,
   dept_no      CHAR(4)         NOT NULL,
   from_date    DATE            NOT NULL,
   to_date      DATE            NOT NULL,
   FOREIGN KEY (emp_no)  REFERENCES employees (emp_no)    ON DELETE CASCADE,
   FOREIGN KEY (dept_no) REFERENCES departments (dept_no) ON DELETE CASCADE,
   PRIMARY KEY (emp_no,dept_no)
);

CREATE TABLE dept_emp (
    emp_no      INT             NOT NULL,
    dept_no     CHAR(4)         NOT NULL,
    from_date   DATE            NOT NULL,
    to_date     DATE            NOT NULL,
    FOREIGN KEY (emp_no)  REFERENCES employees   (emp_no)  ON DELETE CASCADE,
    FOREIGN KEY (dept_no) REFERENCES departments (dept_no) ON DELETE CASCADE,
    PRIMARY KEY (emp_no,dept_no)
);

CREATE TABLE titles (
    emp_no      INT             NOT NULL,
    title       VARCHAR(50)     NOT NULL,
    from_date   DATE            NOT NULL,
    to_date     DATE,
    FOREIGN KEY (emp_no) REFERENCES employees (emp_no) ON DELETE CASCADE,
    PRIMARY KEY (emp_no,title, from_date)
) 
; 

CREATE TABLE salaries (
    emp_no      INT             NOT NULL,
    salary      INT             NOT NULL,
    from_date   DATE            NOT NULL,
    to_date     DATE            NOT NULL,
    FOREIGN KEY (emp_no) REFERENCES employees (emp_no) ON DELETE CASCADE,
    PRIMARY KEY (emp_no, from_date)
) 
; 

CREATE OR REPLACE VIEW dept_emp_latest_date AS
    SELECT emp_no, MAX(from_date) AS from_date, MAX(to_date) AS to_date
    FROM dept_emp
    GROUP BY emp_no;
    
CREATE OR REPLACE VIEW current_dept_emp AS
    SELECT l.emp_no, dept_no, l.from_date, l.to_date
    FROM dept_emp d
        INNER JOIN dept_emp_latest_date l
        ON d.emp_no=l.emp_no AND d.from_date=l.from_date AND l.to_date = d.to_date;
        
## List all employees

select * from employees;

## List all departments

select * from departments;

## Get the names of all employees in a specific department (e.g., "Sales")

select * from dept_emp;


## Get the names of all employees in a specific department (e.g., "Sales")

select first_name, last_name ,dept_name from departments
join dept_emp
on dept_emp.dept_no = departments.dept_no
join employees
on employees.emp_no = dept_emp.emp_no
where dept_name = "Sales";

## Find the total number of employees

select count(*) as No_of_Employees from employees ;


## Find employees with salaries greater than $60,000

select first_name, last_name, salary from employees
join salaries
on employees.emp_no = salaries.emp_no
where salary > 60000;




## Find the average salary by department

select avg(salary) as Avg_Salary, dept_name from salaries
join dept_emp
on salaries.emp_no = dept_emp.emp_no
join departments
on departments.dept_no = dept_emp.dept_no
group by dept_name
order by dept_name desc;


## List all employees who have been with the company for more than 5 years

select first_name, last_name, 
  year(hire_date) as hire_year, 
  year(current_date()) as current_year, 
  year(CURDATE()) - year(hire_date) as no_of_years 
from employees
having 
    no_of_years > 5;
    

## Find the highest salary paid in each department

select dept_name,
       max(salary) as highest_salary
from salaries
join dept_emp on salaries.emp_no = dept_emp.emp_no
join departments on departments.dept_no = dept_emp.dept_no
group by dept_name
order by dept_name desc;


## Find employees who have changed their titles

select emp_no, count(title) as title_changed from titles
group by emp_no
having title_changed > 1;




## Find the employee with the longest tenure:

select first_name, last_name, 
  year(hire_date) as hire_year, 
  year(current_date()) as current_year, 
  year(CURDATE()) - year(hire_date) as tenure_days 
from employees
order by tenure_days desc
limit 1;





## List the number of employees hired each year:

select year(hire_date) as hire_year, count(emp_no) as no_of_employees from employees
group by hire_year
order by hire_year asc;


