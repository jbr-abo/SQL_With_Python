
### We will  conduct necessary bucketing-
WITH 
	cohort AS (				## Defining the cohort
		SELECT
			MONTH(first_purchase_date) AS cohort_month,
			user_id,
			product_line
		FROM
			first_purchases
		ORDER BY 
			1, 2
            ),
        
	seniority AS (        ## Preparing the purchase table for later use
		SELECT
			MONTH(purchase_date) AS month_seniority,
			user_id,
			product_line
		FROM
			purchases
		ORDER BY 
			1, 2
            ),
        
	user_activities AS ( 			## Defining the users' activities in the following moths
		SELECT 
			A.user_id,
			(A.month_seniority - C.cohort_month) AS month_number,
			A.product_line
		FROM
			seniority AS A
		LEFT JOIN
			cohort AS C
		ON
			A.user_id = C.user_id
		GROUP BY
			1, 2
		    ),
        
	cohort_size AS (			## We can find our cohort size this way
		SELECT
			cohort_month,
			COUNt(1) AS num_users,
			product_line
		FROM
			cohort
		GROUP BY 
			1
		ORDER BY
			1
            ),

	 retention_table AS (     ## Setting up our retention table
		SELECT
			C.cohort_month,
			A.month_number,
			COUNt(1) AS num_users,
			A.product_line
		FROM 
			user_activities AS A
			LEFT JOIN
			cohort AS C 
			ON
			A.user_id = C.user_id
		GROUP BY
			1, 2, 4)
            
### Our final query starts from here based on the previously made bucketing-

SELECT 				
	R.cohort_month,
    S.num_users AS total_users,
    R.month_number,
    R.product_line,
    ROUND(CAST(R.num_users AS FLOAT) * 100 / S.num_users, 2) AS retentionPercentage
FROM 
	retention_table AS R
    LEFT JOIN
    cohort_size AS S
    ON
		R.cohort_month = S.cohort_month
    WHERE
		R.cohort_month IS NOT NULL
	ORDER BY
		1, 3;
    
    