const Pool = require('pg').Pool
const pool = new Pool({
    user: 'kendi',
    host: 'localhost',
    database: 'movies_db',
    password: 'kendi',
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

const getMoviebyId = (request, response) => {
  const id = parseInt(request.params.id)
  console.log(id)
  console.log(request.params.id)
  pool.query('SELECT * FROM movies WHERE id = $1', [id], (error, results) => {
    if (error) {
      throw error
    }
    response.status(200).json(results.rows)
  })
}

const deleteMovie = (request, response) => {
  const id = parseInt(request.params.id)

  pool.query('DELETE FROM movies WHERE id = $1', [id], (error, results) => {
    if (error) {
      throw error
    }
    response.status(200).send(`User deleted with ID: ${id}`)
  })
}


// must be review
const updateMovie = (request, response) => {
  const id = parseInt(request.params.id)
  const { title, description } = request.body

  pool.query(
    'UPDATE users SET title = $1, description = $2 WHERE id = $3',
    [title, description, id],
    (error, results) => {
      if (error) {
        throw error
      }
      response.status(200).send(`User modified with ID: ${id}`)
    }
  )
}

module.exports = {
    getMovies,
    getMoviebyId,
    deleteMovie,
    updateMovie,
}