package steps

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"regexp"

	"github.com/git-town/git-town/v7/src/git"
)

// LoadPreviousRunState loads the run state from disk if it exists. Can return nil if there is no previous runstate.
func LoadPreviousRunState(repo *git.ProdRepo) (result *RunState, err error) {
	filename, err := runResultFilename(repo)
	if err != nil {
		return nil, err
	}
	_, err = os.Stat(filename)
	if err != nil {
		if os.IsNotExist(err) {
			return nil, nil //nolint:nilnil
		}
		return nil, fmt.Errorf("cannot check file %q: %w", filename, err)
	}
	var runState RunState
	content, err := ioutil.ReadFile(filename)
	if err != nil {
		return result, fmt.Errorf("cannot read file %q: %w", filename, err)
	}
	err = json.Unmarshal(content, &runState)
	if err != nil {
		return result, fmt.Errorf("cannot parse content of file %q: %w", filename, err)
	}
	return &runState, nil
}

// DeletePreviousRunState deletes the previous run state from disk.
func DeletePreviousRunState(repo *git.ProdRepo) error {
	filename, err := runResultFilename(repo)
	if err != nil {
		return err
	}
	_, err = os.Stat(filename)
	if err != nil {
		if os.IsNotExist(err) {
			return nil
		}
		return fmt.Errorf("cannot check file %q: %w", filename, err)
	}
	err = os.Remove(filename)
	if err != nil {
		return fmt.Errorf("cannot delete file %q: %w", filename, err)
	}
	return nil
}

// SaveRunState saves the run state to disk.
func SaveRunState(runState *RunState, repo *git.ProdRepo) error {
	content, err := json.MarshalIndent(runState, "", "  ")
	if err != nil {
		return fmt.Errorf("cannot encode run-state: %w", err)
	}
	filename, err := runResultFilename(repo)
	if err != nil {
		return err
	}
	err = ioutil.WriteFile(filename, content, 0o600)
	if err != nil {
		return fmt.Errorf("cannot write file %q: %w", filename, err)
	}
	return nil
}

func runResultFilename(repo *git.ProdRepo) (string, error) {
	replaceCharacterRegexp := regexp.MustCompile("[[:^alnum:]]")
	rootDir, err := repo.Silent.RootDirectory()
	if err != nil {
		return "", err
	}
	directory := replaceCharacterRegexp.ReplaceAllString(rootDir, "-")
	return filepath.Join(os.TempDir(), directory), nil
}
