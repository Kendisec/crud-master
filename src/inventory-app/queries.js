const Pool = require('pg').Pool
const pool = new Pool({
    user: 'vagrant',
    host: '192.168.56.12',
    database: 'movies_db',
    password: '',
    port: 5432,
})



const getMovies = (request, response) => {
  pool.query('SELECT * FROM movies ORDER BY id ASC', (error, results) => {
    if (error) {
      throw error
    }
    response.status(200).json(results.rows)
  })
}

module.exports = {
    getMovies,
}