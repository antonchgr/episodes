TRUNCATE TABLE tempdb.dbo.dm_exec_requests_history;
GO
WHILE (1=1)
BEGIN
	INSERT INTO tempdb.dbo.dm_exec_requests_history
	SELECT 
		SYSDATETIME() as capture_datetime,
		r.session_id,
		r.command,
		t.text
	FROM
		sys.dm_exec_requests AS r
	INNER JOIN 
		sys.dm_exec_sessions AS S ON r.session_id=s.session_id
	CROSS APPLY
		sys.dm_exec_sql_text(r.sql_handle) AS t
	WHERE 
		s.is_user_process = 1
		AND
		s.session_id <> @@SPID
		AND
		r.command = 'SELECT (STATMAN)';
END
GO

