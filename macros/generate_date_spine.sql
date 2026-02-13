{% macro generate_date_spine(start_date, end_date) %}
    WITH date_spine AS (
        SELECT 
            DATE_ADD(
                DATE('{{ start_date }}'),
                INTERVAL x DAY
            ) AS date_day
        FROM UNNEST(GENERATE_ARRAY(0, DATE_DIFF(DATE('{{ end_date }}'), DATE('{{ start_date }}'), DAY))) AS x
    )
    SELECT date_day FROM date_spine
{% endmacro %}
